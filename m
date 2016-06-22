From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 14:52:34 -0700
Message-ID: <576B08A2.8080603@hpe.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:2361 "EHLO
	g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbcFVVwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 17:52:37 -0400
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com [15.233.44.26])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id 5AEB7614C2
	for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 21:52:36 +0000 (UTC)
In-Reply-To: <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/22/2016 11:22 AM, Yuval Mintz wrote:
> But seriously, this isn't really anything new but rather a step forward in
> the direction we've already taken - bnx2x/qede are already performing
> the same for non-encapsulated TCP.

Since you mention bnx2x...   I would argue that the NIC firmware on 
those NICs driven by bnx2x is doing it badly.  Not so much from a 
functional standpoint I suppose, but from a performance one.  The 
NIC-firmware GRO done there has this rather unfortunate assumption about 
"all MSSes will be directly driven by my own physical MTU" and when it 
sees segments of a size other than would be suggested by the physical 
MTU, will coalesce only two segments together.  They then do not get 
further coalesced in the stack.

Suffice it to say this does not do well from a performance standpoint.

One can disable LRO via ethtool for these NICs, but what that does is 
disable old-school LRO, not GRO-in-the-NIC.  To get that disabled, one 
must also get the bnx2x module loaded with "disable-tpa=1" so the Linux 
stack GRO gets used instead.

Had the bnx2x-driven NICs' firmware not had that rather unfortunate 
assumption about MSSes I probably would never have noticed.

happy benchmarking,

rick jones
