From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 2/7] be2net: Checksum field valid only for
 TCP/UDP
Date: Thu, 10 Mar 2011 16:05:09 -0800
Message-ID: <20110311000509.GA28596@ram-laptop>
References: <79e10ac8-3f25-4ee2-9a0d-08d39cd9fe9c@exht1.ad.emulex.com>
Reply-To: Ram Pai <linuxram@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Sathya Perla <sathya.perla@emulex.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:48741 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754331Ab1CKAFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 19:05:15 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2ANcmT0021107
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 18:38:48 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C6E396E803E
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 19:05:14 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2B05EYG206002
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 19:05:14 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2B05De0015288
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 21:05:14 -0300
Content-Disposition: inline
In-Reply-To: <79e10ac8-3f25-4ee2-9a0d-08d39cd9fe9c@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 06:38:16PM +0530, Padmanabh Ratnakar wrote:
> L4 checksum field is valid only for TCP/UDP packets in Lancer
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> Signed-off-by: Subramanian Seetharaman <subbu.seetharaman@emulex.com>
> ---
>  drivers/net/benet/be_main.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
> index bf34434..ac7ae21 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -865,14 +865,17 @@ static void be_rx_stats_update(struct be_rx_obj *rxo,
> 
>  static inline bool csum_passed(struct be_eth_rx_compl *rxcp)
>  {
> -	u8 l4_cksm, ipv6, ipcksm;
> +	u8 l4_cksm, ipv6, ipcksm, tcpf, udpf;
> 
>  	l4_cksm = AMAP_GET_BITS(struct amap_eth_rx_compl, l4_cksm, rxcp);
>  	ipcksm = AMAP_GET_BITS(struct amap_eth_rx_compl, ipcksm, rxcp);
>  	ipv6 = AMAP_GET_BITS(struct amap_eth_rx_compl, ip_version, rxcp);
> +	tcpf = AMAP_GET_BITS(struct amap_eth_rx_compl, tcpf, rxcp);
> +	udpf = AMAP_GET_BITS(struct amap_eth_rx_compl, udpf, rxcp);
> 
> -	/* Ignore ipcksm for ipv6 pkts */
> -	return l4_cksm && (ipcksm || ipv6);
> +	/* L4 checksum is not reliable for non TCP/UDP packets.
> +	 * Also ignore ipcksm for ipv6 pkts */
> +	return (tcpf || udpf) && l4_cksm && (ipcksm || ipv6);

Is it invalid for non-Lancer too ?  if not, then should'nt the
above condition be applied only for lancer?

RP
