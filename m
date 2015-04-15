From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question] TCP stack performance decrease since 3.14
Date: Wed, 15 Apr 2015 15:13:54 -0700
Message-ID: <1429136034.7346.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <552EBCA8.6090408@psc.edu>
	 <1429131712.7346.144.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EDA4D.7040308@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rapier <rapier@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34760 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780AbbDOWNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 18:13:55 -0400
Received: by iget9 with SMTP id t9so92587167ige.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 15:13:55 -0700 (PDT)
In-Reply-To: <552EDA4D.7040308@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 17:38 -0400, rapier wrote:

> I believe I properly disabled CPU power management in the bios (the 
> lenovo bios isn't terribly clear on this). I then booted with 
> processor.max_cstate=1 idle=poll (also tried with 
> intel_idle.max_cstate=0 and combinatiosn thereof). Still seeing reduced 
> performance in comparison to 3.14. I'll try using /dev/cpu_dma_latency 
> instead when I get in tomorrow. If you have other suggestions to verify 
> c-state I'd be happy to hear them.
> 
> As a note, 3.2 tests as being more than 18% faster in the above categories.

Wait a minute, are you testing tcp on a single laptop over loopback ?

multiple netperf consume a lot of ram and any change in kernel vmlinux
size can impact the performance simply because your cpu cache is too
small to cope with the increase.

Between 3.2 and 4.0 kernel, TCP networking changes are maybe 2 % of
overall changes.

2.6.1 kernel in 32bit mode will be much faster you know.

Maybe 40% faster.

# ls -l /boot/vmlinuz-*
-rwxr-xr-x 1 root root 3719696 2015-04-15 14:09 /boot/vmlinuz-3.14.0-smp
-rwxr-xr-x 1 root root 3911520 2015-04-15 14:30 /boot/vmlinuz-4.0.0-smp
