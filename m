From: Florian Weimer <fweimer@redhat.com>
Subject: Re: Kernel uapi and glibc header conflicts (was Re: header conflict
 introduced by change to netfilter_ipv4/ip_tables.h )
Date: Mon, 8 Feb 2016 14:59:17 +0100
Message-ID: <56B89F35.1050908@redhat.com>
References: <20160106092007.1c5a0c75@xeon-e3>
 <88a455d4b6dc4d4398553e6529d7b94a@HQ1WP-EXMB11.corp.brocade.com>
 <20160107103040.649ab878@xeon-e3> <20160207113111.GE6104@lakka.kapsi.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, libc-alpha@sourceware.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Mikko Rapeli <mikko.rapeli@iki.fi>,
        Stephen Hemminger <shemming@brocade.com>
Return-path: <libc-alpha-return-66916-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <20160207113111.GE6104@lakka.kapsi.fi>
List-Id: netdev.vger.kernel.org

On 02/07/2016 12:31 PM, Mikko Rapeli wrote:
> On Thu, Jan 07, 2016 at 10:30:40AM -0800, Stephen Hemminger wrote:
>> On Thu, 7 Jan 2016 07:29:50 +0000
>> Mikko Rapeli <mikko.rapeli@iki.fi> wrote:
>>
>>> On Wed, Jan 06, 2016 at 09:20:07AM -0800, Stephen Hemminger wrote:
>>>> This commit breaks compilation of iproute2 with net-next.
>>>
>>> Ok, linux/if.h and libc net/if.h have overlapping defines, and this is not
>>> the only one. I saw lots of them in the core dump headers.
>>>
>>> How should we handle them? Another ifndef for IFNAMSIZ into kernel uapi
>>> headers?
>>>
>>> -Mikko
>>
>> Probably need to do the same thing that was done previously for these
>> kind of conflicts.  This makes make linux/if.h change to adapt to net/if.h
>> being included before it.
> 
> So uapi headers now have a libc-compat.h
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/libc-compat.h?id=refs/tags/v4.5-rc2
> which tries to detect and fix incompatibilities between Linux kernel and glibc
> headers. Part of the fix is then in the kernel side headers and another part
> should be in glibc headers, but glibc git repo does not include any of these
> fixes yet.
> 
> Has the glibc part of this incompatiblity mess been discussed and agreed
> with glibc developers?

I don't remember any recent discussions on libc-alpha, or any bug
reports about this concrete change.

(Redirecting to libc-alpha, which seems the more appropriate list.)

> Many of the conflics arise from propably old glibc headers which had copied
> out definitions from the Linux kernel side before it could export any headers
> to userspace. I assume that the glibc headers are not allowed to depend and
> include Linux kernel uapi headers in deployments but maybe the Linux kernel
> headers could be used at glibc compile time to generate needed glibc side
> definitions. That would allow having a single source for definitions like 
> FNAMSIZ 16.

My impression is that this inconsistency isn't the only problem.  The
problems start if application developers need functionality which is
only in kernel-provided headers, but they still need to include glibc
headers at the same time.

> I'm drafting a test, similar to the kernel uapi header compile test
> https://github.com/mcfrisk/linux/blob/headers_test_v05/scripts/headers_compile_test.sh
> for the glibc conflicts too, and of course noticed that also glibc headers
> conflict with each other. With some workarounds I can test compile each kernel
> uapi header against all compiling glibc headers and see the conflicts as
> build failures.

That could be helpful.

I'm not familiar with relevant developer practices.  It seems to me that
from an application developer point of view, kernel headers are updated
a bit more frequently than glibc headers.  This likely pushes the
solution into a certain direction (and may be the rationale behind the
kernel's libc-compat.h).

Florian
