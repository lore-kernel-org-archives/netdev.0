From: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Subject: Kernel uapi and glibc header conflicts (was Re: header conflict
 introduced by change to netfilter_ipv4/ip_tables.h )
Date: Sun, 7 Feb 2016 13:31:11 +0200
Message-ID: <20160207113111.GE6104@lakka.kapsi.fi>
References: <20160106092007.1c5a0c75@xeon-e3>
 <88a455d4b6dc4d4398553e6529d7b94a@HQ1WP-EXMB11.corp.brocade.com>
 <20160107103040.649ab878@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libc-help-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <shemming-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>
Return-path: <libc-help-return-3732-gclgu-libc-help=m.gmane.org-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>
List-Unsubscribe: <mailto:libc-help-unsubscribe-gclgu-libc-help=m.gmane.org-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>
List-Subscribe: <mailto:libc-help-subscribe-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>
List-Post: <mailto:libc-help-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>
List-Help: <mailto:libc-help-help-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>, <http://sourceware.org/lists.html#faqs>
Sender: libc-help-owner-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20160107103040.649ab878@xeon-e3>
List-Id: netdev.vger.kernel.org

On Thu, Jan 07, 2016 at 10:30:40AM -0800, Stephen Hemminger wrote:
> On Thu, 7 Jan 2016 07:29:50 +0000
> Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org> wrote:
> 
> > On Wed, Jan 06, 2016 at 09:20:07AM -0800, Stephen Hemminger wrote:
> > > This commit breaks compilation of iproute2 with net-next.
> > 
> > Ok, linux/if.h and libc net/if.h have overlapping defines, and this is not
> > the only one. I saw lots of them in the core dump headers.
> > 
> > How should we handle them? Another ifndef for IFNAMSIZ into kernel uapi
> > headers?
> > 
> > -Mikko
> 
> Probably need to do the same thing that was done previously for these
> kind of conflicts.  This makes make linux/if.h change to adapt to net/if.h
> being included before it.

So uapi headers now have a libc-compat.h
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/libc-compat.h?id=refs/tags/v4.5-rc2
which tries to detect and fix incompatibilities between Linux kernel and glibc
headers. Part of the fix is then in the kernel side headers and another part
should be in glibc headers, but glibc git repo does not include any of these
fixes yet.

Has the glibc part of this incompatiblity mess been discussed and agreed
with glibc developers?

Many of the conflics arise from propably old glibc headers which had copied
out definitions from the Linux kernel side before it could export any headers
to userspace. I assume that the glibc headers are not allowed to depend and
include Linux kernel uapi headers in deployments but maybe the Linux kernel
headers could be used at glibc compile time to generate needed glibc side
definitions. That would allow having a single source for definitions like 
FNAMSIZ 16.

Has this been considered before?

I'm drafting a test, similar to the kernel uapi header compile test
https://github.com/mcfrisk/linux/blob/headers_test_v05/scripts/headers_compile_test.sh
for the glibc conflicts too, and of course noticed that also glibc headers
conflict with each other. With some workarounds I can test compile each kernel
uapi header against all compiling glibc headers and see the conflicts as
build failures.

-Mikko
