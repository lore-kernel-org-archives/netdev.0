From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH][TG3]Some cleanups
Date: Tue, 02 Oct 2007 16:33:53 -0700
Message-ID: <1191368033.5961.22.camel@dell>
References: <1191175890.6165.17.camel@localhost>
 <1191284504.25892.129.camel@dell> <1191328627.4353.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>,
	"netdev" <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2662 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554AbXJBWew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 18:34:52 -0400
In-Reply-To: <1191328627.4353.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-02 at 08:37 -0400, jamal wrote:
> The simplest solution seems to me to modify the definition of
> TG3_SKB_CB
> as i did for e1000 from:
> (struct tg3_tx_cbdata *)&((__skb)->cb[0])
> to:
> (struct tg3_tx_cbdata *)&((__skb)->cb[8])
> 
> that way the vlan tags are always present and no need to recreate
> them.
> What do you think?

Seems ok to me.  I think we should make it more clear that we're
skipping over the VLAN tag:

(struct tg3_tx_cbdata *)&((__skb)->cb[sizeof(struct vlan_skb_tx_cookie)])

