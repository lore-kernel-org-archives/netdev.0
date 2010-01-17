From: Christian Samsel <christian.samsel@rwth-aachen.de>
Subject: Re: [PATCH 1/2] improve netem reorder flexibility
Date: Sun, 17 Jan 2010 13:11:18 +0100
Message-ID: <201001171311.19278.christian.samsel@rwth-aachen.de>
References: <200912181901.28542.christian.samsel@rwth-aachen.de>
 <20091221095407.5430a630@nehalam>
 <20100116.014654.69913255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: shemminger@vyatta.com, christian.samsel@rwth-aachen.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:51926 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751996Ab0AQMLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 07:11:19 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KWE008R74IUCP70@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sun, 17 Jan 2010 13:11:18 +0100 (CET)
Received: from oxygen-mobile.localnet ([unknown] [80.135.51.144])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0KWE006UR4IUF050@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Sun, 17 Jan 2010 13:11:18 +0100 (CET)
In-reply-to: <20100116.014654.69913255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, 16. Januar 2010 10:46:54 schrieb David Miller:
> 
> This is a really dangerous way to handle this.
> 
> This means if you grow qopt, older kernels think that the
> extended area is attributes.
> 
> This also means that if you have new tools and send a qopt +
> attributes, older kernels won't find the start of the attributes
> correctly.  It will miss the attributes entirely.
True, i know now. 

> This is a complete mess, and we need to sort it out before we think
> about changing the size of qopt at this point.
> 
Just to state this clearly, by cleaning up the mess you mean switching netem 
completely over to netlink attributes? 

I think 4B3A5F84.4050603@yahoo.it would also take advantage of that. The 
approach they choosed looks a bit wierd to me,  cause someday we could end up 
having 
tc qdisc add dev eth0 root netem
tc qdisc add dev eth0 root netem2
tc qdisc add dev eth0 root netem3
..

Christian
