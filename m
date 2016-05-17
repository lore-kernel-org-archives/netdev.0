From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Tue, 17 May 2016 16:43:20 +0200
Message-ID: <20160517164320.46e03c81@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-5-git-send-email-simon.horman@netronome.com>
	<CAOrHB_AMC4x=NnLTpGbXdW31Vp0f1R3VoaD9ksST5EesrdGsug@mail.gmail.com>
	<20160506055705.GA9276@penelope.isobedori.kobe.vergenet.net>
	<20160506112514.47f6e9dc@griffin>
	<20160509080420.GA4470@vergenet.net>
	<20160510140106.367936fb@griffin>
	<20160511015009.GB24436@vergenet.net>
	<20160511030632.GA24805@vergenet.net>
	<20160511160928.27816400@griffin>
	<20160511224650.GA12481@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48384 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbcEQOnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 10:43:25 -0400
In-Reply-To: <20160511224650.GA12481@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 May 2016 07:46:52 +0900, Simon Horman wrote:
> If we can live with a bogus skb->mac_len value that is sufficient for
> ovs_flow_key_extract.() and set correctly by key_extract() (which happens
> anyway) we could do something like this:
> 
> 	} else if (vport->dev->type == ARPHRD_NONE) {
> 		if (skb->protocol == htons(ETH_P_TEB))
> 			/* Ignores presence of VLAN but is sufficient for
> 			 * ovs_flow_key_extract() which then calls key_extract()
> 			 * which calculates skb->mac_len correctly. */
> 			skb->mac_len = ETH_HLEN; /* Ignores presence of VLAN */
> 		else
> 			skb->mac_len = 0;
> 	}
> 
> 
> But perhaps I have missed the point somehow.

You did not, I was more thinking aloud. But you're right, it doesn't
make much sense.

So, wouldn't it be actually more correct and in line with patch 2 to
call eth_type_trans() here? Possibly even followed by skb_vlan_untag
(not needed. But it might make things easier to have the first vlan tag
always reside inside skb->vlan_tci and treat that as an invariant in
the whole ovs kernel code. It'll need to be done in more spots than
just this one, though, and is probably matter of a separate patchset).

 Jiri
