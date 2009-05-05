From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: bond + tc regression ?
Date: Tue, 05 May 2009 18:45:58 +0300
Message-ID: <1241538358.27647.9.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:1173 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbZEEQLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 12:11:50 -0400
Received: from [127.0.0.1] (localhost.localdomain [127.0.0.1])
	by mail.yourdomain.com (8.14.1/8.14.1) with ESMTP id n45Fjw8R028182
	for <netdev@vger.kernel.org>; Tue, 5 May 2009 18:45:58 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a traffic policing setup running on Linux, serving about 800 mbps
of traffic. Due to the traffic growth I decided to employ network
interface bonding to scale over a single GigE.

The Sun X4150 server has 2xIntel E5450 QuadCore CPUs and a total of four
built-in e1000e interfaces, which I grouped into two bond interfaces.

With kernel 2.6.23.1, everything works fine, but the system locked up
after a few days.

With kernel 2.6.28.7/2.6.29.1, I get 10-20% packet loss. I get packet loss as
soon as I put a classful qdisc, even prio, without even having any
classes or filters. TC prio statistics report lots of drops, around 10k
per sec. With exactly the same setup on 2.6.23, the number of drops is
only 50 per sec.

On both kernels, the system is running with at least 70% idle CPU.
The network interrupts are distributed accross the cores.

I thought it was a e1000e driver issue, but tweaking e1000e ring buffers
didn't help. I tried using e1000 on 2.6.28 by adding necessary PCI IDs,
I tried running on a different server with bnx cards, I tried disabling
NO_HZ and HRTICK, but still I have the same problem.

However, if I don't utilize bond, but just apply rules on normal ethX
interfaces, there is no packet loss with 2.6.28/29. 

So, the problem appears only when I use 2.6.28/29 + bond + classful tc
combination. 

Any ideas ?

-- 
Best Regards,
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel PLC, Cyprus - www.prime-tel.com
Tel: +357 25 100100 Fax: +357 2210 2211


