From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [WIP] [PATCH] WAS Re: [RFC] New driver API to speed up small packets
 xmits
Date: Thu, 17 May 2007 10:31:56 +0530
Message-ID: <OFD4E8C537.53B7FE22-ON652572DE.001ABA41-652572DE.001BA4ED@in.ibm.com>
References: <464B7B49.4070003@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: ak@suse.de, ashwin.chaugule@celunite.com,
	David Miller <davem@davemloft.net>,
	Gagan Arneja <gagan@vmware.com>, hadi@cyberus.ca,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rdreier@cisco.com, xma@us.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:45119 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbXEQFCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 01:02:53 -0400
In-Reply-To: <464B7B49.4070003@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala <sri@us.ibm.com> wrote on 05/17/2007 03:14:41 AM:

> Krishna Kumar2 wrote:
> > Hi Sridhar,
> >
> > Sridhar Samudrala <sri@us.ibm.com> wrote on 05/17/2007 03:42:03 AM:
> >
> >> AFAIK, gso_skb can be a list of skb's. Can we add a list
> >> to another list using __skb_queue_head()?
> >> Also, if gso_skb is a list of multiple skb's, i think the
> >> count needs to be decremented by the number of segments in
> >> gso_skb.
> >
> > gso_skb is the last GSO skb that failed to be sent. This already
> > segmented skb is kept "cached" and whenever the next xmit happens,
> > this skb is first sent before any packets from the queue are taken
> > out (otherwise out-of-order packets). So there can atmost be one
> > gso_skb per device.
>
> Yes. There can be only one gso_skb per device. But it can have more
> than one segments linked together via skb->next.

It will definitely have more than 1 segments (criterea to be on the
gso_skb). But I think you are right, the segmented skb will "lose"
it's 1-n segments (newsk->next = next) when it is added to the list.

Thanks,

- KK

