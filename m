From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v4 net 2/3] sctp: Use software crc32 checksum when xfrm
 transform will happen.
Date: Wed, 16 Oct 2013 09:32:53 -0400
Message-ID: <20131016133253.GB10623@neilslaptop.think-freely.org>
References: <1381888891-31186-1-git-send-email-vyasevich@gmail.com>
 <1381888891-31186-3-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	fan.du@windriver.com,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56692 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760554Ab3JPNdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 09:33:02 -0400
Content-Disposition: inline
In-Reply-To: <1381888891-31186-3-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 10:01:30PM -0400, Vlad Yasevich wrote:
> From: Fan Du <fan.du@windriver.com>
> 
> igb/ixgbe have hardware sctp checksum support, when this feature is enabled
> and also IPsec is armed to protect sctp traffic, ugly things happened as
> xfrm_output checks CHECKSUM_PARTIAL to do checksum operation(sum every thing
> up and pack the 16bits result in the checksum field). The result is fail
> establishment of sctp communication.
> 
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Fan Du <fan.du@windriver.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> ---
>  net/sctp/output.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 0ac3a65..d35b54c 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -536,7 +536,8 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>  	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
>  	 */
>  	if (!sctp_checksum_disable) {
> -		if (!(dst->dev->features & NETIF_F_SCTP_CSUM)) {
> +		if (!(dst->dev->features & NETIF_F_SCTP_CSUM) ||
> +		    (dst_xfrm(dst) != NULL)) {
>  			__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
>  
>  			/* 3) Put the resultant value into the checksum field in the
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
