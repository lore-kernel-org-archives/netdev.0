From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v3 1/3] sctp: Export struct sctp_info to userspace
Date: Thu, 4 Aug 2016 16:40:21 +0200
Message-ID: <20160804144021.GD8988@orbyte.nwl.cc>
References: <1470305517-31880-1-git-send-email-phil@nwl.cc>
 <1470305517-31880-2-git-send-email-phil@nwl.cc>
 <20160804133329.GA11579@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47247 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751820AbcHDOsg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 10:48:36 -0400
Content-Disposition: inline
In-Reply-To: <20160804133329.GA11579@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 04, 2016 at 09:33:29AM -0400, Neil Horman wrote:
> On Thu, Aug 04, 2016 at 12:11:55PM +0200, Phil Sutter wrote:
> > This is required to correctly interpret INET_DIAG_INFO messages exported
> > by sctp_diag module.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  include/linux/sctp.h      | 64 -----------------------------------------------
> >  include/uapi/linux/sctp.h | 64 +++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 64 insertions(+), 64 deletions(-)
> > 
> > diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> > index de1f64318fc4e..fcb4c36461732 100644
> > --- a/include/linux/sctp.h
> > +++ b/include/linux/sctp.h
> > @@ -705,70 +705,6 @@ typedef struct sctp_auth_chunk {
> >  	sctp_authhdr_t auth_hdr;
> >  } __packed sctp_auth_chunk_t;
> >  
> > -struct sctp_info {
> > -	__u32	sctpi_tag;
> > -	__u32	sctpi_state;
> > -	__u32	sctpi_rwnd;
> > -	__u16	sctpi_unackdata;
> > -	__u16	sctpi_penddata;
> > -	__u16	sctpi_instrms;
> > -	__u16	sctpi_outstrms;
> > -	__u32	sctpi_fragmentation_point;
> > -	__u32	sctpi_inqueue;
> > -	__u32	sctpi_outqueue;
> > -	__u32	sctpi_overall_error;
> > -	__u32	sctpi_max_burst;
> > -	__u32	sctpi_maxseg;
> > -	__u32	sctpi_peer_rwnd;
> > -	__u32	sctpi_peer_tag;
> > -	__u8	sctpi_peer_capable;
> > -	__u8	sctpi_peer_sack;
> > -	__u16	__reserved1;
> > -
> > -	/* assoc status info */
> > -	__u64	sctpi_isacks;
> > -	__u64	sctpi_osacks;
> > -	__u64	sctpi_opackets;
> > -	__u64	sctpi_ipackets;
> > -	__u64	sctpi_rtxchunks;
> > -	__u64	sctpi_outofseqtsns;
> > -	__u64	sctpi_idupchunks;
> > -	__u64	sctpi_gapcnt;
> > -	__u64	sctpi_ouodchunks;
> > -	__u64	sctpi_iuodchunks;
> > -	__u64	sctpi_oodchunks;
> > -	__u64	sctpi_iodchunks;
> > -	__u64	sctpi_octrlchunks;
> > -	__u64	sctpi_ictrlchunks;
> > -
> > -	/* primary transport info */
> > -	struct sockaddr_storage	sctpi_p_address;
> > -	__s32	sctpi_p_state;
> > -	__u32	sctpi_p_cwnd;
> > -	__u32	sctpi_p_srtt;
> > -	__u32	sctpi_p_rto;
> > -	__u32	sctpi_p_hbinterval;
> > -	__u32	sctpi_p_pathmaxrxt;
> > -	__u32	sctpi_p_sackdelay;
> > -	__u32	sctpi_p_sackfreq;
> > -	__u32	sctpi_p_ssthresh;
> > -	__u32	sctpi_p_partial_bytes_acked;
> > -	__u32	sctpi_p_flight_size;
> > -	__u16	sctpi_p_error;
> > -	__u16	__reserved2;
> > -
> > -	/* sctp sock info */
> > -	__u32	sctpi_s_autoclose;
> > -	__u32	sctpi_s_adaptation_ind;
> > -	__u32	sctpi_s_pd_point;
> > -	__u8	sctpi_s_nodelay;
> > -	__u8	sctpi_s_disable_fragments;
> > -	__u8	sctpi_s_v4mapped;
> > -	__u8	sctpi_s_frag_interleave;
> > -	__u32	sctpi_s_type;
> > -	__u32	__reserved3;
> > -};
> > -
> >  struct sctp_infox {
> >  	struct sctp_info *sctpinfo;
> >  	struct sctp_association *asoc;
> > diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> > index d304f4c9792c4..a406adcc0793e 100644
> > --- a/include/uapi/linux/sctp.h
> > +++ b/include/uapi/linux/sctp.h
> > @@ -944,4 +944,68 @@ struct sctp_default_prinfo {
> >  	__u16 pr_policy;
> >  };
> >  
> > +struct sctp_info {
> > +	__u32	sctpi_tag;
> > +	__u32	sctpi_state;
> > +	__u32	sctpi_rwnd;
> > +	__u16	sctpi_unackdata;
> > +	__u16	sctpi_penddata;
> > +	__u16	sctpi_instrms;
> > +	__u16	sctpi_outstrms;
> > +	__u32	sctpi_fragmentation_point;
> > +	__u32	sctpi_inqueue;
> > +	__u32	sctpi_outqueue;
> > +	__u32	sctpi_overall_error;
> > +	__u32	sctpi_max_burst;
> > +	__u32	sctpi_maxseg;
> > +	__u32	sctpi_peer_rwnd;
> > +	__u32	sctpi_peer_tag;
> > +	__u8	sctpi_peer_capable;
> > +	__u8	sctpi_peer_sack;
> > +	__u16	__reserved1;
> > +
> > +	/* assoc status info */
> > +	__u64	sctpi_isacks;
> > +	__u64	sctpi_osacks;
> > +	__u64	sctpi_opackets;
> > +	__u64	sctpi_ipackets;
> > +	__u64	sctpi_rtxchunks;
> > +	__u64	sctpi_outofseqtsns;
> > +	__u64	sctpi_idupchunks;
> > +	__u64	sctpi_gapcnt;
> > +	__u64	sctpi_ouodchunks;
> > +	__u64	sctpi_iuodchunks;
> > +	__u64	sctpi_oodchunks;
> > +	__u64	sctpi_iodchunks;
> > +	__u64	sctpi_octrlchunks;
> > +	__u64	sctpi_ictrlchunks;
> > +
> > +	/* primary transport info */
> > +	struct sockaddr_storage	sctpi_p_address;
> > +	__s32	sctpi_p_state;
> > +	__u32	sctpi_p_cwnd;
> > +	__u32	sctpi_p_srtt;
> > +	__u32	sctpi_p_rto;
> > +	__u32	sctpi_p_hbinterval;
> > +	__u32	sctpi_p_pathmaxrxt;
> > +	__u32	sctpi_p_sackdelay;
> > +	__u32	sctpi_p_sackfreq;
> > +	__u32	sctpi_p_ssthresh;
> > +	__u32	sctpi_p_partial_bytes_acked;
> > +	__u32	sctpi_p_flight_size;
> > +	__u16	sctpi_p_error;
> > +	__u16	__reserved2;
> > +
> > +	/* sctp sock info */
> > +	__u32	sctpi_s_autoclose;
> > +	__u32	sctpi_s_adaptation_ind;
> > +	__u32	sctpi_s_pd_point;
> > +	__u8	sctpi_s_nodelay;
> > +	__u8	sctpi_s_disable_fragments;
> > +	__u8	sctpi_s_v4mapped;
> > +	__u8	sctpi_s_frag_interleave;
> > +	__u32	sctpi_s_type;
> > +	__u32	__reserved3;
> > +};
> > +
> If you export these, shouldn't they be converted to the corresponding
> uint<size>_t variants?

As mentioned earlier, uapi headers using the __u* types seems not
uncommon. Another aspect is consistency, these types are used throughout
the whole file already, so if I should change them, they all should be
changed. And assuming uapi/linux/tcp.h being a good example: struct
tcp_info uses them also.

Cheers, Phil
