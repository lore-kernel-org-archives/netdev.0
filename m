From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: [EXAMPLE CODE] Parasite thread injection and TCP connection hijacking
Date: Sat, 6 Aug 2011 09:15:45 -0400
Message-ID: <CAObL_7FeZQpnOzpXHqSviZdBRUCL+rODbQOBb+6JPSd3PB=fig@mail.gmail.com>
References: <20110806121247.GC23937@htj.dyndns.org> <4E3D3768.3070108@mit.edu> <20110806130037.GD23937@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Nathan Lynch <ntl@pobox.com>,
	Oren Laadan <orenl@cs.columbia.edu>,
	Daniel Lezcano <dlezcano@fr.ibm.com>, S@mit.edu,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:42489 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922Ab1HFNQF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 09:16:05 -0400
In-Reply-To: <20110806130037.GD23937@htj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 6, 2011 at 9:00 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Sat, Aug 06, 2011 at 08:45:28AM -0400, Andy Lutomirski wrote:
>> > 2. Decide where to inject the foreign code and save the original c=
ode
>> > =A0 =A0with PTRACE_PEEKDATA. =A0Tracer can poke any mapped area re=
gardless
>> > =A0 =A0of protection flags but it can't add execution permission t=
o the
>> > =A0 =A0code, so it needs to choose memory area which already has X=
 flag
>> > =A0 =A0set. =A0The example code uses the page the %rip is in.
>>
>> If the process is executing from the vsyscall page, then you'll
>> probably fail. =A0(Admittedly, this is rather unlikely, given that t=
he
>> vsyscalls are now exactly one instruction.) =A0Presumably you also
>> fail if executing from a read-only MAP_SHARED mapping.
>
> Heh, yeah, I originally thought about scanning /proc/PID/maps to look
> for the page to use but was lazy and just used %rip. =A0I think that
> should work. =A0I'll note the problem in README.
>
>> Windows has a facility to more-or-less call mmap on behalf of
>> another process, and another one to directly inject a thread into a
>> remote process. =A0It's traditional to use them for this type of
>> manipulation. Perhaps Linux should get the same thing. =A0(Although
>> you could accomplish much the same thing if you could create a task
>> with your mm but the tracee's fs.)
>
> Actually, the only thing we need on x86_64 is two bytes for the
> syscall instruction because all params are passed through registers
> anyway. =A0We can just set up parameters for mmap, turn on single ste=
p,
> point %rip to syscall in the vsyscall page. =A0So, either way, I don'=
t
> think this would be too difficult to solve.

Not any more -- that syscall instruction is gone as of 3.1.  You could
search through the vdso to find a syscall, but that seems fragile.

Why not just add a ptrace command to issue a syscall?

--Andy
