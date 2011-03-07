From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] net: harmonize the call to ptype_all and
 ptype_base handlers.
Date: Mon, 7 Mar 2011 11:03:19 +0100
Message-ID: <20110307100318.GD2832@psychotron.brq.redhat.com>
References: <4D738751.6050209@gmail.com>
 <1299417916-14198-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?= <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755578Ab1CGKD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 05:03:29 -0500
Content-Disposition: inline
In-Reply-To: <1299417916-14198-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 06, 2011 at 02:25:16PM CET, nicolas.2p.debian@free.fr wrote:
>Until now, ptype_all and ptype_base delivery in __netif_receive_skb() =
is
>inconsistent.
>
>- For ptype_all, we deliver to every device crossed while walking the
>rx_handler path (inside the another_round loop), and there is no way t=
o stop
>wildcard delivery (no exact match logic).
>- For ptype_base, we deliver to the lowest device (orig_dev) and to th=
e highest
>(skb->dev) and we can ask for exact match delivery.
>
>This patch try and fix this, by:
>
>1/ Doing exact match delivery for both ptype_all and ptype_base, while=
 walking
>   the rx_handler path.
>2/ Doing wildcard match delivery at the end of __netif_receive_skb(), =
if not
>   asked to do exact match delivery only.
>
>Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>---
>
>This apply on top of the last batch of patch from Jiri Pirko.
>---
> net/core/dev.c |   32 ++++++++++++++++++++++++--------
> 1 files changed, 24 insertions(+), 8 deletions(-)
>

I tend to like this patch. However I'm not sure if extra 2 loops don't
introduce noticable overhead :/
