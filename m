From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: kernel bug in socketpair()
Date: 23 Jul 2003 18:50:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058982641.5520.98.camel@dhcp22.swansea.linux.org.uk>
References: <200307231428.KAA15254@raptor.research.att.com>
	 <20030723074615.25eea776.davem@redhat.com>
	 <200307231656.MAA69129@raptor.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, dgk@research.att.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Glenn Fowler <gsf@research.att.com>
In-Reply-To: <200307231656.MAA69129@raptor.research.att.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mer, 2003-07-23 at 17:56, Glenn Fowler wrote:
> you can eliminate the security implications for all fd types by
> simply translating
> 	open("/dev/fd/N",...)
> to
> 	dup(atoi(N))
> w.r.t. fd N in the current process

This has very different semantics. Consider lseek().

> otherwise there is a bug in the /dev/fd/N -> /proc/self/fd/N implementation
> and /dev/fd/N should be separated out to its (original) dup(atoi(N))
> semantics

I don't see a bug. I see differing behaviour between Linux and BSD on a
completely non standards defined item. Also btw nobody ever really wrote
a /dev/fd/ for Linux - it was just a byproduct of the proc stuff someone
noticed. I guess someone could write a Plan-9 style dev/fd or devfdfs
for Linux if they wanted.

Alan
