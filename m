From: Anthony Liguori <aliguori@us.ibm.com>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 05 Apr 2007 09:32:12 -0500
Message-ID: <4615086C.9060306@us.ibm.com>
References: <4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com> <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com> <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com> <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu> <1175728768.12230.593.camel@localhost.localdomain> <20070405093033.GC25448@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:35815 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbXDEOcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 10:32:20 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l35EU5Hg001015
	for <netdev@vger.kernel.org>; Thu, 5 Apr 2007 10:30:05 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l35EWJ2d109942
	for <netdev@vger.kernel.org>; Thu, 5 Apr 2007 08:32:19 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l35EWITb024983
	for <netdev@vger.kernel.org>; Thu, 5 Apr 2007 08:32:19 -0600
In-Reply-To: <20070405093033.GC25448@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Rusty Russell <rusty@rustcorp.com.au> wrote:
>
>   
>> It's easier to write a kernel-space network driver, but it's not 
>> obviously the right thing to do until we can show that an efficient 
>> packet-level userspace interface isn't possible.  I don't think that's 
>> been done, and it would be interesting to try.
>>     
>
> yes, i agree in theory, but IMO this is largely beside the point. What 
> matters most for developing a project is _the quality of the codebase_. 
> That attracts developers, developers improve the code, which then 
> attracts users, which attracts more developers, etc., etc. As long as 
> the quality of the codebase is maintained, this is a self-sustaining 
> process. You've seen that happen with Linux. [ And of course, the 
> crutial step #0 is: a sane, open-minded maintainer with good taste ;-) ]
>
> qemu's code quality is not really suitable for that basic OSS model, in 
> my opinion.

I think you may want to step off your high horse there.  QEMU's code may 
not be Linux kernel quality but it's certainly not anywhere near the 
worst that is out there.  Linux is over decade old.  QEMU is only around 
3 years old.  Did Linux have extremely high quality code in 1994?  
Instead of posting code snippets to LKML, it would be much more 
constructive to post patches to qemu-devel.  It's not like the QEMU 
maintainers are actively ignoring your efforts to improve the code.

> but architectural issues aside (ignoring that the kernel _is_ the best 
> place to do this particular of stuff),

Right.  We don't put things in the kernel just because we don't like the 
way the userspace code is written.  If that logic was valid, then Linus 
would be working on moving all of Gnome into the kernel.

This discussion has two parts.  The first is whether or not the kernel 
is the right place for a paravirtual network driver backend.  My current 
believe is that we could not get enough performance from something like 
tun to do it in userspace.  I also believe that we could improve tun (or 
create a replacement) so that we could implement a PV network driver 
backend in userspace.  Admittedly, I'm not an expert in networking 
though so I could be wrong here.

The second part is whether the platform devices should go in the 
kernel.  I agree with you that having the PIT in the kernel is probably 
a good idea.  I also agree that we probably have no choice but to move 
the APIC into the kernel (not for PV drivers, but for TPR performance 
and SMP support).

Regards,

Anthony Liguori

>  this question is still mainly 
> dominated by the basic question of code quality. I'd rather move 
> something into the Linux kernel, enforce its code quality that way, and 
> _then_ add whatever clean infrastructure is needed to push it back into 
> user-space again (into a different codebase), than having to hack the 
> monolithic 200 KLOC+ qemu codebase that is shackled with support for 
> tons of arcane architectures nobody uses and tons of arcane OS variants 
> that no-one cares about. Now qemu is a very important enabler and 
> platform-reference-implementation for KVM to fall back to, but it's not 
> the place to put crutial new code into, at least currently.
>
> 	Ingo
>   

