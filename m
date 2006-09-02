From: James Morris <jmorris@namei.org>
Subject: Re: [IPSEC]: searching  SAD without assumming L3 details
Date: Sat, 2 Sep 2006 11:04:40 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609021102570.4222@d.namei>
References: <1157204582.5197.4.camel@jzny2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:30881 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750767AbWIBPEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 11:04:44 -0400
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1157204582.5197.4.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2 Sep 2006, jamal wrote:

> Against net-2.6.19
> 
> signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

+xfrm_stateonly_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
+               unsigned short family, u32 reqid, u8 mode, u8 proto)
+{
+       unsigned int h = xfrm_dst_hash(daddr, saddr, 0, family);
+       struct xfrm_state *rx = NULL, *x = NULL;
+       struct hlist_node *entry;
+       
+       spin_lock(&xfrm_state_lock);

Shouldn't this be spin_lock_bh()?

+       spin_unlock(&xfrm_state_lock);
+
+       if (rx)
+               xfrm_state_hold(rx);

I think you need to grab the reference before letting go of the lock.


Can you please include patches inline, or tell me how to get pine to 
quote attachments? :-)


-- 
James Morris
<jmorris@namei.org>

-- 
VGER BF report: U 0.5
