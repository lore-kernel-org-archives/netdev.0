From: Stefan Bauer <sb@plzk.de>
Subject: Re: ip link macvtap interface not processing specific ipv6
 multicast traffic without promiscuous mode on
Date: Wed, 15 Apr 2015 10:21:55 +0200
Message-ID: <1429086115.3383.36.camel@plzk.de>
References: <1428574167.2171.32.camel@plzk.de>
	 <1428598288.2759.2.camel@plzk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay05.ispgateway.de ([80.67.31.97]:40110 "EHLO
	smtprelay05.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbbDOIV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 04:21:59 -0400
Received: from [87.185.75.237] (helo=zarafa)
	by smtprelay05.ispgateway.de with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <sb@plzk.de>)
	id 1YiIa4-0007te-FZ
	for netdev@vger.kernel.org; Wed, 15 Apr 2015 10:21:56 +0200
Received: from s1 (unknown [192.168.0.151])
	by zarafa (Postfix) with ESMTP id 2E438220064
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 10:21:55 +0200 (CEST)
In-Reply-To: <1428598288.2759.2.camel@plzk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I could narrow down the problem. Win7Prof and Windows 10 is having this
issue.

Win Client is member of the multicast group and is listening on
ff02::1:ffdf:fe88

Traffic from router -> client - captured on router:

07:41:23.104567 IP6 fe80::12fe:edff:fee6:cfa > ff02::1:ffdf:fe88: ICMP6,
neighbor solicitation, who has 2a01:198:200:8350:851e:21a7:28df:fe88,
length 32
07:41:24.099764 IP6 fe80::12fe:edff:fee6:cfa > ff02::1:ffdf:fe88: ICMP6,
neighbor solicitation, who has 2a01:198:200:8350:851e:21a7:28df:fe88,
length 32
07:41:25.099772 IP6 fe80::12fe:edff:fee6:cfa > ff02::1:ffdf:fe88: ICMP6,
neighbor solicitation, who has 2a01:198:200:8350:851e:21a7:28df:fe88,
length 32


Traffic from router to client - captured on KVM HOST

09:41:23.106444 IP6 fe80::12fe:edff:fee6:cfa > ff02::1:ffdf:fe88: ICMP6,
neighbor solicitation, who has 2a01:198:200:8350:851e:21a7:28df:fe88,
length 32
09:41:24.101647 IP6 fe80::12fe:edff:fee6:cfa > ff02::1:ffdf:fe88: ICMP6,
neighbor solicitation, who has 2a01:198:200:8350:851e:21a7:28df:fe88,
length 32
09:41:25.101718 IP6 fe80::12fe:edff:fee6:cfa > ff02::1:ffdf:fe88: ICMP6,
neighbor solicitation, who has 2a01:198:200:8350:851e:21a7:28df:fe88,
length 32

No traffic seen on KVM GUEST (win7 or win10) with wireshark

Any ideas to debug this further?

Cheers

Stefan
