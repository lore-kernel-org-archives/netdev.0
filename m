From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 1/6] sctp: add sctp_info dump api for
 sctp_diag
Date: Fri, 08 Apr 2016 22:16:24 -0700
Message-ID: <1460178984.6473.473.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
	 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:33007 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbcDIFQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 01:16:28 -0400
In-Reply-To: <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-09 at 12:53 +0800, Xin Long wrote:
> sctp_diag will dump some important details of sctp's assoc or ep, we use
> sctp_info to describe them,  sctp_get_sctp_info to get them, and export
> it to sctp_diag.ko.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/linux/sctp.h    | 65 +++++++++++++++++++++++++++++++++++++
>  include/net/sctp/sctp.h |  3 ++
>  net/sctp/socket.c       | 86 +++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 154 insertions(+)
> 
> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> index a9414fd..a448ebc 100644
> --- a/include/linux/sctp.h
> +++ b/include/linux/sctp.h
> @@ -705,4 +705,69 @@ typedef struct sctp_auth_chunk {
>  	sctp_authhdr_t auth_hdr;
>  } __packed sctp_auth_chunk_t;
>  
> +struct sctp_info {
> +	__u32	sctpi_tag;
> +	__u32	sctpi_state;
> +	__u32	sctpi_rwnd;
> +	__u16	sctpi_unackdata;
> +	__u16	sctpi_penddata;
> +	__u16	sctpi_instrms;
> +	__u16	sctpi_outstrms;
> +	__u32	sctpi_fragmentation_point;
> +	__u32	sctpi_inqueue;
> +	__u32	sctpi_outqueue;
> +	__u32	sctpi_overall_error;
> +	__u32	sctpi_max_burst;
> +	__u32	sctpi_maxseg;
> +	__u32	sctpi_peer_rwnd;
> +	__u32	sctpi_peer_tag;
> +	__u8	sctpi_peer_capable;
> +	__u8	sctpi_peer_sack;
> +
> +	/* assoc status info */
> +	__u64	sctpi_isacks;
> +	__u64	sctpi_osacks;
> +	__u64	sctpi_opackets;
> +	__u64	sctpi_ipackets;
> +	__u64	sctpi_rtxchunks;
> +	__u64	sctpi_outofseqtsns;
> +	__u64	sctpi_idupchunks;
> +	__u64	sctpi_gapcnt;
> +	__u64	sctpi_ouodchunks;
> +	__u64	sctpi_iuodchunks;
> +	__u64	sctpi_oodchunks;
> +	__u64	sctpi_iodchunks;
> +	__u64	sctpi_octrlchunks;
> +	__u64	sctpi_ictrlchunks;
> +
> +	/* primary transport info */
> +	struct sockaddr_storage	sctpi_p_address;
> +	__s32	sctpi_p_state;
> +	__u32	sctpi_p_cwnd;
> +	__u32	sctpi_p_srtt;
> +	__u32	sctpi_p_rto;
> +	__u32	sctpi_p_hbinterval;
> +	__u32	sctpi_p_pathmaxrxt;
> +	__u32	sctpi_p_sackdelay;
> +	__u32	sctpi_p_sackfreq;
> +	__u32	sctpi_p_ssthresh;
> +	__u32	sctpi_p_partial_bytes_acked;
> +	__u32	sctpi_p_flight_size;
> +	__u16	sctpi_p_error;
> +
> +	/* sctp sock info */
> +	__u32	sctpi_s_autoclose;
> +	__u32	sctpi_s_adaptation_ind;
> +	__u32	sctpi_s_pd_point;
> +	__u8	sctpi_s_nodelay;
> +	__u8	sctpi_s_disable_fragments;
> +	__u8	sctpi_s_v4mapped;
> +	__u8	sctpi_s_frag_interleave;
> +};
> +

Lots of holes in this structure...
