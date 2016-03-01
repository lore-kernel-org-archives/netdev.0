From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v3.16] r8169: Increase no descriptors on max.
Date: Tue, 1 Mar 2016 10:31:58 -0800
Message-ID: <20160301103158.069d6978@xeon-e3>
References: <1456817225-2026-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35124 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbcCASbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 13:31:46 -0500
Received: by mail-pf0-f172.google.com with SMTP id w128so72728514pfb.2
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 10:31:45 -0800 (PST)
In-Reply-To: <1456817225-2026-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 Mar 2016 09:27:05 +0200
Corcodel Marian <asd@marian1000.go.ro> wrote:

>   This patch increase rx/tx on maximum allowed 1024 4-duble-words
>   descriptors.
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index e215812..5fd3fca 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -84,8 +84,8 @@ static const int multicast_filter_limit = 32;
>  
>  #define R8169_REGS_SIZE		256
>  #define R8169_NAPI_WEIGHT	64
> -#define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
> -#define NUM_RX_DESC	256U	/* Number of Rx descriptor registers */
> +#define NUM_TX_DESC	1024	/* Number of Tx descriptor registers */
> +#define NUM_RX_DESC	1024U	/* Number of Rx descriptor registers */
>  #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
>  #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
>  

I can see why you would want to do this to get better small packet
performance, but there is a serious downside.  Increasing the ring
size can mean significantly increased bufferbloat. With jumbo frames
a full ring of 1024 packets is 73ms.

The r8169 driver does not support a couple of things that would help
with bufferbloat. It doesn't support tuning the ring sizes
with ethtool. And it doesn't support BQL.

If you really want to do this, better to support ethtool ring size control
and leave the default alone, but allow larger values by override.
