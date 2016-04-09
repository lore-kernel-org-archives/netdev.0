From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCHv2 net-next 1/6] sctp: add sctp_info dump api for sctp_diag
Date: Sat, 9 Apr 2016 11:16:06 -0400
Message-ID: <57091CB6.1070207@mojatatu.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37459 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982AbcDIPQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 11:16:21 -0400
Received: by mail-ig0-f177.google.com with SMTP id g8so39389556igr.0
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 08:16:20 -0700 (PDT)
In-Reply-To: <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Appreciate these patches. Finally some love for sctp.
Small comment below:

On 16-04-09 12:53 AM, Xin Long wrote:
> sctp_diag will dump some important details of sctp's assoc or ep, we use
> sctp_info to describe them,  sctp_get_sctp_info to get them, and export
> it to sctp_diag.ko.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>   include/linux/sctp.h    | 65 +++++++++++++++++++++++++++++++++++++
>   include/net/sctp/sctp.h |  3 ++
>   net/sctp/socket.c       | 86 +++++++++++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 154 insertions(+)
>
> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> index a9414fd..a448ebc 100644
> --- a/include/linux/sctp.h
> +++ b/include/linux/sctp.h
> @@ -705,4 +705,69 @@ typedef struct sctp_auth_chunk {
>   	sctp_authhdr_t auth_hdr;
>   } __packed sctp_auth_chunk_t;
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


Can you double check to make sure this is 32 bit aligned
(no holes) maybe in your case 64 bit aligned?
Sticking  +	__u16	sctpi_p_error in there seems
to kill it.

Also, any plans to do the netlink events and destroy features?

cheers,
jamal
