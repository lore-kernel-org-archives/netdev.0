From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: bond + tc regression ?
Date: Fri, 08 May 2009 23:46:11 +0300
Message-ID: <1241815571.7242.48.camel@hazard2.francoudi.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com>
	 <200905062230.04594.denys@visp.net.lb>
	 <20090506204759.GA16681@francoudi.com>
	 <200905070046.27551.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:3963 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092AbZEHUqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 16:46:15 -0400
In-Reply-To: <200905070046.27551.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > Without IRQ balancing, one of the cores goes around 10% idle and HTB
> > doesn't do its job properly. Actually, in my experience HTB stops working
> > properly after idle goes below 35%.
> It seems they should. No idea, more experienced guys should know more.
> 
> Can you show me please
> cat /proc/net/psched
> If it is highres working, try to add in HTB script, first line
> 
> HZ=1000
> to set environment variable. Because if clock resolution high, burst 
> calculation going crazy on high speeds.
> Maybe it will help.

Wow, instead of 98425b burst, its calculating 970203b. 

Exporting HZ=1000 doesn't help. However, even if I recompile the kernel
to 1000 Hz and the burst is calculated correctly, for some reason HTB on
2.6.29 is still worse at rate control than 2.6.21.

With 2.6.21, ceil of 775 mbits, burst 99425b -> actual rate 825 mbits.
With 2.6.29, same ceil/burst -> actual rate 890 mbits.

Moreover, after I stop the traffic *COMPLETELY* on 2.6.29, actual rate
reported by htb goes ballistic and stays at 1100mbits. Then it drops
back to expected value after a minute or so.

> Also without irq balance, did you try to assign interface to cpu by 
> smp_affinity? (/proc/irq/NN/smp_affinity)

Yes, I did, didn't make any difference.

> And still i think best thing is oprofile. It can show "hot" places in code, 
> who is spending cpu cycles.

For some reason I get a hard freeze when I start oprofile daemon, even
without traffic. Never used oprofile before, so I'm not sure if I'm
doing something wrong ... I'm starting it just with --vmlinux parameter
and nothing else. I use vanilla 2.6.29 and oprofile from FC8.

-- 
Best Regards,
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel PLC, Cyprus - www.prime-tel.com
Tel: +357 25 100100 Fax: +357 2210 2211


