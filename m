From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Mon, 18 Mar 2013 17:07:52 -0700
Message-ID: <1363651672.21184.17.camel@edumazet-glaptop>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	 <1363625464-21633-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:57603 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144Ab3CSAHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 20:07:55 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so985727pdi.19
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 17:07:54 -0700 (PDT)
In-Reply-To: <1363625464-21633-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 18:51 +0200, Dmitry Kravkov wrote:
> The patch drives FW to perform RSS for GRE traffic,
> based on inner headers.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    3 +++
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c  |   23 ++++++++++++-----------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h  |    9 +++++++++
>  3 files changed, 24 insertions(+), 11 deletions(-)

This works very well.

Problem is we skb_set_queue_mapping(skb, 0); in __skb_tunnel_rx()

(this was a patch from Tom Herbert, commit
693019e90ca45d881109d32c0c6d29adf03f6447 (net: reset skb queue mapping
when rx'ing over tunnel )

Meaning we hit a single cpu for the GRO stuff in ip_gre.

I have to think about it.


Another question is : 

Can bnx2x check the tcp checksum if GRE encapsulated ?
