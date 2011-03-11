From: <Padmanabh.Ratnakar@Emulex.Com>
Subject: RE: [PATCH net-next-2.6 2/7] be2net: Checksum field valid only for
 TCP/UDP
Date: Fri, 11 Mar 2011 02:04:41 -0800
Message-ID: <e7b170e0-03a6-48c7-9afd-6005ae3a5ae2@exht2.ad.emulex.com>
References: <79e10ac8-3f25-4ee2-9a0d-08d39cd9fe9c@exht1.ad.emulex.com>
 <20110311000509.GA28596@ram-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<Sathya.Perla@Emulex.Com>, <subbu.seetharaman@emulex.com>
To: <linuxram@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:1728 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751388Ab1CKKKT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 05:10:19 -0500
In-Reply-To: <20110311000509.GA28596@ram-laptop>
Content-Language: en-US
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

> Is it invalid for non-Lancer too ?  if not, then should'nt the
> above condition be applied only for lancer?

> RP

There is no need to apply this condition only for Lancer. This check works for BE too.
In BE, for non-tcp/udp packets l4_csum is always 0.

Thanks,
Padmanabh
