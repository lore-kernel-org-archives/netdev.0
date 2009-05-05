From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: bond + tc regression ?
Date: Tue, 5 May 2009 19:25:50 +0300
Message-ID: <200905051925.50142.denys@visp.net.lb>
References: <1241538358.27647.9.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50752 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbZEEQZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 12:25:56 -0400
In-Reply-To: <1241538358.27647.9.camel@hazard2.francoudi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can you show example of rules you are putting?
Probably i can find mistakes and give correct example and i will explain maybe 
why it is happened.


On Tuesday 05 May 2009 18:45:58 Vladimir Ivashchenko wrote:
> Hi,
>
> I have a traffic policing setup running on Linux, serving about 800 mbps
> of traffic. Due to the traffic growth I decided to employ network
> interface bonding to scale over a single GigE.
>
> The Sun X4150 server has 2xIntel E5450 QuadCore CPUs and a total of four
> built-in e1000e interfaces, which I grouped into two bond interfaces.
>
> With kernel 2.6.23.1, everything works fine, but the system locked up
> after a few days.
>
> With kernel 2.6.28.7/2.6.29.1, I get 10-20% packet loss. I get packet loss
> as soon as I put a classful qdisc, even prio, without even having any
> classes or filters. TC prio statistics report lots of drops, around 10k per
> sec. With exactly the same setup on 2.6.23, the number of drops is only 50
> per sec.
>
> On both kernels, the system is running with at least 70% idle CPU.
> The network interrupts are distributed accross the cores.
>
> I thought it was a e1000e driver issue, but tweaking e1000e ring buffers
> didn't help. I tried using e1000 on 2.6.28 by adding necessary PCI IDs,
> I tried running on a different server with bnx cards, I tried disabling
> NO_HZ and HRTICK, but still I have the same problem.
>
> However, if I don't utilize bond, but just apply rules on normal ethX
> interfaces, there is no packet loss with 2.6.28/29.
>
> So, the problem appears only when I use 2.6.28/29 + bond + classful tc
> combination.
>
> Any ideas ?


