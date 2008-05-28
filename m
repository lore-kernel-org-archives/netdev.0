From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 23:09:13 +0300
Message-ID: <200805282309.13628.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <200805282102.02805.opurdila@ixiacom.com> <483DBA0D.8090402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3229 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752967AbYE1UKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 16:10:25 -0400
In-Reply-To: <483DBA0D.8090402@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 May 2008, Jarek Poplawski wrote:

> >> We queue data under the lock and clone appropriate skb (and then grab it
> >> multiple times), so even it will be dropped, its data will not freed,
> >> and thus we will be able to read it. Or you are talking about different
> >> skbs?
> >
> > You are right, I forgot about the clone.
>
> Probably I miss something, but how does it help when tcp_collapse()
> uses __kfree_skb()?
>

__kfree_skb() -> skb_release_all() -> skb_release_data():

static void skb_release_data(struct sk_buff *skb)
{
        if (!skb->cloned ||
<snip>
                kfree(skb->head);

Since we clone the skb in skb_splice_bits() the skb's data will only be freed 
when the last clone is deleted.

tavi
