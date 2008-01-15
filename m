From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Tue, 15 Jan 2008 11:14:25 -0600
Message-ID: <478CE9F1.8020409@nortel.com>
References: <20080115071950.GA1696@ff.dom.local>	<478CC76B.1020804@nortel.com> <20080115161705.0724250d@astralstorm.puszkin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Radoslaw Szkodzinski (AstralStorm)" <lkml@astralstorm.puszkin.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:56464 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbYAORO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 12:14:56 -0500
In-Reply-To: <20080115161705.0724250d@astralstorm.puszkin.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Radoslaw Szkodzinski (AstralStorm) wrote:
> On Tue, 15 Jan 2008 08:47:07 -0600
> "Chris Friesen" <cfriesen@nortel.com> wrote:

>>Some of our hardware is not supported on mainline, so we need per-kernel 
>>version patches to even bring up the blade.  The blades netboot via a 
>>jumbo-frame network, so kernel extensions are needed to handle setting 
>>the MTU before mounting the rootfs.

> Why? Can't you use a small initramfs to set it up?

Sure, if we changed our build system, engineered a suitable small 
userspace, etc.  At this point it's easier to maintain a small patch to 
the kernel dhcp parsing code so that we can specify mtu.

>>The blade in question uses CKRM 
>>which doesn't exist for newer kernels so the problem may simply be 
>>hidden by scheduling differences.

> Current spiritual successor is Ingo's realtime patchset I guess.

I think the group scheduling stuff for CFS is closer, but there are 
design and API differences that would require us to rework our system.

>>The userspace application uses other 
>>kernel features that are not in mainline (and likely some of them won't 
>>ever be in mainline--I know because I've tried).

> What would these be? Some proc or sysfs files that were removed or
> renamed?
> Maybe they can be worked around w/o changing the application at all, or
> very minor changes.

No, more than proc/sysfs.  Things like notification of process state 
change (think like SIGCHLD but sent to arbitrary processes), additional 
messaging protocol families, oom-killer protection, dirty page 
monitoring, backwards compatibility for "dcbz" on the ppc970, nested 
alternate signal stacks, and many others.  Between our kernel vendor's 
patches and our own, there are something like 600 patches applied to the 
mainline kernel.

> Also, be sure to check if there are pauses with other CPU hogs.

With the sctp hash patch applied we're now sitting with 45% cpu free on 
one cpu, and about 25% free on the other, and we're still seeing 
periodic bursts of rx fifo loss.  It's wierd.  Still trying to figure 
out what's going on.

Chris
