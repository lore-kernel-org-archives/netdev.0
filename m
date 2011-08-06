From: Tejun Heo <tj@kernel.org>
Subject: Re: [EXAMPLE CODE] Parasite thread injection and TCP connection
 hijacking
Date: Sat, 6 Aug 2011 15:00:37 +0200
Message-ID: <20110806130037.GD23937@htj.dyndns.org>
References: <20110806121247.GC23937@htj.dyndns.org>
 <4E3D3768.3070108@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Nathan Lynch <ntl@pobox.com>,
	Oren Laadan <orenl@cs.columbia.edu>,
	Daniel Lezcano <dlezcano@fr.ibm.com>, S@mit.edu,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andy Lutomirski <luto@MIT.EDU>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E3D3768.3070108@mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, Aug 06, 2011 at 08:45:28AM -0400, Andy Lutomirski wrote:
> > 2. Decide where to inject the foreign code and save the original code
> >    with PTRACE_PEEKDATA.  Tracer can poke any mapped area regardless
> >    of protection flags but it can't add execution permission to the
> >    code, so it needs to choose memory area which already has X flag
> >    set.  The example code uses the page the %rip is in.
> 
> If the process is executing from the vsyscall page, then you'll
> probably fail.  (Admittedly, this is rather unlikely, given that the
> vsyscalls are now exactly one instruction.)  Presumably you also
> fail if executing from a read-only MAP_SHARED mapping.

Heh, yeah, I originally thought about scanning /proc/PID/maps to look
for the page to use but was lazy and just used %rip.  I think that
should work.  I'll note the problem in README.

> Windows has a facility to more-or-less call mmap on behalf of
> another process, and another one to directly inject a thread into a
> remote process.  It's traditional to use them for this type of
> manipulation. Perhaps Linux should get the same thing.  (Although
> you could accomplish much the same thing if you could create a task
> with your mm but the tracee's fs.)

Actually, the only thing we need on x86_64 is two bytes for the
syscall instruction because all params are passed through registers
anyway.  We can just set up parameters for mmap, turn on single step,
point %rip to syscall in the vsyscall page.  So, either way, I don't
think this would be too difficult to solve.

Thanks.

-- 
tejun
