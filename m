From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [WIP][PATCHES] Network xmit batching - tg3 support
Date: Mon, 02 Jul 2007 14:20:44 -0700
Message-ID: <1183411245.6609.16.camel@teletran1>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
 <1181216629.4064.22.camel@localhost>
 <20070619132148.GA32078@2ka.mipt.ru>
 <20070619133333.GA19667@2ka.mipt.ru>
 <20070619140038.GA13629@2ka.mipt.ru>
 <1182270529.4968.73.camel@localhost>
 <18040.5105.715624.286924@robur.slu.se>
 <1182275300.4968.83.camel@localhost>
 <1182989145.5155.81.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Robert Olsson" <Robert.Olsson@data.slu.se>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Krishna Kumar2" <krkumar2@in.ibm.com>,
	"Gagan Arneja" <gaagaan@gmail.com>, netdev@vger.kernel.org,
	"Rick Jones" <rick.jones2@hp.com>,
	"Sridhar Samudrala" <sri@us.ibm.com>,
	"David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Michael Chan" <mchan@broadcom.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1993 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754838AbXGBVVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 17:21:11 -0400
In-Reply-To: <1182989145.5155.81.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-27 at 20:05 -0400, jamal wrote:
> peoplez,
> 
> I have added support for tg3 on batching. I see equivalent performance
> improvement for pktgen as i did with e1000 when using gige. 
> I have only tested on two machines (one being a laptop which does
> 10/100Mbps). Unfortunately in both cases these are considered to be in
> the class of  "buggy" tg3s (which take a longer code path).
> 
> To the tg3 folks - can you double check if am off on something?
> I have split a few things that you may like as well.
> I havent upgraded the tree - it is still circa 2.6.22-rc4 based; at some
> point i will sync with Daves net-26
> 
> Anyone who has tg3 based hardware: I would appreciate any testing and
> results ...
> 
> The git tree is at:
> git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git
> but i have attached the patch in case you just wanna stare.
> 
> cheers,
> jamal

Hi Jamal.  I'll be testing your patch soon, but I wanted to point out a
bug in the patch.  The patch defines TG3_SKB_CB() as follows :

#define TG3_SKB_CB(__skb) ((struct tg3_tx_cbdata *)&((__skb)->cb[0]))

This definition will collide with the VLAN macros if TG3_VLAN_TAG_USED
is set.  vlan_tx_tag_get() is defined as :

#define vlan_tx_tag_get(__skb)  (VLAN_TX_SKB_CB(__skb)->vlan_tag)

VLAN_TX_SKB_CB is defined as :

#define VLAN_TX_SKB_CB(__skb) \
        ((struct vlan_skb_tx_cookie *)&((__skb)->cb[0]))

Also, I think the count, max_per_txd, and nr_frags fields of the
tg3_tx_cbdata struct are not needed.

