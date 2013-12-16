From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC v2 08/13] xfrm: Add xfrm_tunnel_skb_cb to the skb
 common buffer
Date: Mon, 16 Dec 2013 14:02:18 +0100
Message-ID: <20131216130218.GJ31491@secunet.com>
References: <20131216091835.GQ31491@secunet.com>
 <20131216092349.GY31491@secunet.com>
 <52AEF7F2.6040903@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57194 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771Ab3LPNCV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 08:02:21 -0500
Content-Disposition: inline
In-Reply-To: <52AEF7F2.6040903@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 01:54:10PM +0100, Nicolas Dichtel wrote:
> Le 16/12/2013 10:23, Steffen Klassert a =E9crit :
> >IPsec vti_rcv needs to remind the tunnel pointer to
> >check it later at the vti_rcv_cb callback. So add
> >this pointer to the IPsec common buffer.
> >
> >Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> >---
> >  include/net/xfrm.h |   29 +++++++++++++++++------------
> >  1 file changed, 17 insertions(+), 12 deletions(-)
> >
> >diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> >index 2c39cd4..584d0ee4 100644
> >--- a/include/net/xfrm.h
> >+++ b/include/net/xfrm.h
> >@@ -600,16 +600,27 @@ struct xfrm_mgr {
> >  int xfrm_register_km(struct xfrm_mgr *km);
> >  int xfrm_unregister_km(struct xfrm_mgr *km);
> >
> >+struct xfrm_tunnel_skb_cb {
> >+	union {
> >+		struct inet_skb_parm h4;
> >+		struct inet6_skb_parm h6;
> >+        } header;
> Nitpicking: this line is aligned with spaces instead tabs (yes, it's
> a copy and paste ;-)).

No problem, will fix it.
Thanks for looking at the vti patches :)
