From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [WIP] [PATCH] WAS Re: [RFC] New driver API to speed up small	packets
 xmits
Date: Thu, 17 May 2007 09:33:34 +0530
Message-ID: <OFBB67F1E7.ABE3C092-ON652572DE.0015BA9F-652572DE.00164CF8@in.ibm.com>
References: <1179353523.10414.12.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: ak@suse.de, ashwin.chaugule@celunite.com,
	David Miller <davem@davemloft.net>,
	Gagan Arneja <gagan@vmware.com>, hadi@cyberus.ca,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rdreier@cisco.com, xma@us.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:48483 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758484AbXEQEEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 00:04:25 -0400
In-Reply-To: <1179353523.10414.12.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sridhar,

Sridhar Samudrala <sri@us.ibm.com> wrote on 05/17/2007 03:42:03 AM:

> AFAIK, gso_skb can be a list of skb's. Can we add a list
> to another list using __skb_queue_head()?
> Also, if gso_skb is a list of multiple skb's, i think the
> count needs to be decremented by the number of segments in
> gso_skb.

gso_skb is the last GSO skb that failed to be sent. This already
segmented skb is kept "cached" and whenever the next xmit happens,
this skb is first sent before any packets from the queue are taken
out (otherwise out-of-order packets). So there can atmost be one
gso_skb per device.

- KK

