From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 19:27:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723192706.A962@ti21>
References: <200307231428.KAA15254@raptor.research.att.com> <20030723074615.25eea776.davem@redhat.com> <200307231656.MAA69129@raptor.research.att.com> <1058982641.5520.98.camel@dhcp22.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Glenn Fowler <gsf@research.att.com>, davem@redhat.com,
   dgk@research.att.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1058982641.5520.98.camel@dhcp22.swansea.linux.org.uk>; from alan@lxorguk.ukuu.org.uk on Wed, Jul 23, 2003 at 06:50:41PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2003 at 06:50:41PM +0100, Alan Cox wrote:
> > otherwise there is a bug in the /dev/fd/N -> /proc/self/fd/N implementation
> > and /dev/fd/N should be separated out to its (original) dup(atoi(N))
> > semantics
>
> I don't see a bug. I see differing behaviour between Linux and BSD on a
> completely non standards defined item. Also btw nobody ever really wrote
> a /dev/fd/ for Linux - it was just a byproduct of the proc stuff someone
> noticed. I guess someone could write a Plan-9 style dev/fd or devfdfs
> for Linux if they wanted.

I first posted about this several years ago, and it came up again earlier
in the year; see:

http://hypermail.idiosynkrasia.net/linux-kernel/archived/2003/week14/0314.html

As HPA and I had previously discussed, ->open() methods always return
a new file struct, so providing the dup() semantics would require a
restructuring of the ->open() methods -- unless, (and this is a dirty
hack,) one creates a devfdfs that abuses the ERESTART_RESTARTBLOCK
mechanism to restart the open() syscall with dup() instead.  This requires
some minor pollution to the open() syscall path to interpret the error
return, but should require no other changes.

Regards,

        Bill Rugolsky
