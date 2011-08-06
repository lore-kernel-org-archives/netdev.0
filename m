From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: SCTP patch reviewer
Date: Sun, 7 Aug 2011 00:34:11 +0900
Message-ID: <B11D49C7-D2AC-4CB6-9BE9-3CBA9D8CFEF6@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:33912 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751412Ab1HFPmO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 11:42:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

I posted these patches 2 months ago; Wei Yongjun initially looked at them
but now i am getting bounces his email address is no longer valid. Can anybody
help me please?

Thanks,
- Michio

Begin forwarded message:

> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: June 16, 2011 5:56:29 PM GMT+09:00
> To: David Miller <davem@davemloft.net>, Wei Yongjun <yjwei@cn.fujitsu.com>
> Cc: netdev@vger.kernel.org
> Subject: [PATCH 0/2] sctp: patches for HEARTBEAT bug fix and improvement
> 
> From 111463f295a5ea7ae03c26bf62671895e803bc28 Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Thu, 16 Jun 2011 17:40:04 +0900
> Subject: [PATCH 0/2]  sctp: patches for HEARTBEAT bug fix and improvement
> 
> Series of 2 patches for bug fix and improvement around HEARTBEAT after the 
> ASCONF event
> 
> Michio Honda (2):
>  sctp: HEARTBEAT negotiation after ASCONF
>  sctp: Bundle HEAERTBEAT into ASCONF_ACK
> 
> include/net/sctp/structs.h |    1 +
> net/sctp/associola.c       |    1 +
> net/sctp/outqueue.c        |    4 ++++
> net/sctp/sm_make_chunk.c   |    1 +
> net/sctp/sm_statefuns.c    |    5 +++++
> 5 files changed, 12 insertions(+), 0 deletions(-)
> 
> -- 
> 1.7.3.2
> 
> 
Begin forwarded message:

> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: June 16, 2011 5:56:42 PM GMT+09:00
> To: David Miller <davem@davemloft.net>, Wei Yongjun <yjwei@cn.fujitsu.com>
> Cc: netdev@vger.kernel.org
> Subject: [PATCH 1/2] sctp: HEARTBEAT negotiation after ASCONF
> 
> From 6780e27850126dc200a8700a0f8c3105971b8978 Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Thu, 16 Jun 2011 10:54:23 +0900
> Subject: [PATCH 1/2] sctp: HEARTBEAT negotiation after ASCONF
> 
> This patch fixes BUG that the ASCONF receiver transmits DATA chunks
> to the newly added UNCONFIRMED destination.
> 
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
> net/sctp/outqueue.c |    4 ++++
> 1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index edc7532..4adfc1e 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -917,6 +917,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
> 		 * current cwnd).
> 		 */
> 		if (!list_empty(&q->retransmit)) {
> +			if (asoc->peer.retran_path->state == SCTP_UNCONFIRMED) 
> +				goto sctp_flush_out;
> 			if (transport == asoc->peer.retran_path)
> 				goto retran;
> 
> @@ -989,6 +991,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
> 			    ((new_transport->state == SCTP_INACTIVE) ||
> 			     (new_transport->state == SCTP_UNCONFIRMED)))
> 				new_transport = asoc->peer.active_path;
> +			if (new_transport->state == SCTP_UNCONFIRMED) 
> +				continue;
> 
> 			/* Change packets if necessary.  */
> 			if (new_transport != transport) {
> -- 
> 1.7.3.2
> 
> 
Begin forwarded message:

> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: June 16, 2011 5:56:52 PM GMT+09:00
> To: David Miller <davem@davemloft.net>, Wei Yongjun <yjwei@cn.fujitsu.com>
> Cc: netdev@vger.kernel.org
> Subject: [PATCH 2/2] sctp: Bundle HEAERTBEAT into ASCONF_ACK
> 
> From 111463f295a5ea7ae03c26bf62671895e803bc28 Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Thu, 16 Jun 2011 17:14:34 +0900
> Subject: [PATCH 2/2] sctp: Bundle HEAERTBEAT into ASCONF_ACK
> 
> With this patch a HEARTBEAT chunk is bundled into the ASCONF-ACK
> for ADD IP ADDRESS, confirming the new destination as quickly as
> possible.
> 
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
> include/net/sctp/structs.h |    1 +
> net/sctp/associola.c       |    1 +
> net/sctp/sm_make_chunk.c   |    1 +
> net/sctp/sm_statefuns.c    |    5 +++++
> 4 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 31d7ea2..7154980 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1915,6 +1915,7 @@ struct sctp_association {
> 	__u32 addip_serial;
> 	union sctp_addr *asconf_addr_del_pending;
> 	int src_out_of_asoc_ok;
> +	struct sctp_transport *new_transport;
> 
> 	/* SCTP AUTH: list of the endpoint shared keys.  These
> 	 * keys are provided out of band by the user applicaton
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index dc16b90..152b5b3 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -282,6 +282,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
> 		asoc->peer.asconf_capable = 1;
> 	asoc->asconf_addr_del_pending = NULL;
> 	asoc->src_out_of_asoc_ok = 0;
> +	asoc->new_transport = NULL;
> 
> 	/* Create an input queue.  */
> 	sctp_inq_init(&asoc->base.inqueue);
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 3363d37..a42d3b0 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3016,6 +3016,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
> 		/* Start the heartbeat timer. */
> 		if (!mod_timer(&peer->hb_timer, sctp_transport_timeout(peer)))
> 			sctp_transport_hold(peer);
> +		asoc->new_transport = peer;
> 		break;
> 	case SCTP_PARAM_DEL_IP:
> 		/* ADDIP 4.3 D7) If a request is received to delete the
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index a297283..5cfd6d2 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -3612,6 +3612,11 @@ sctp_disposition_t sctp_sf_do_asconf(const struct sctp_endpoint *ep,
> 	 */
> 	asconf_ack->dest = chunk->source;
> 	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(asconf_ack));
> +	if (asoc->new_transport) {
> +	        sctp_sf_heartbeat(ep, asoc, type, asoc->new_transport,
> +                    commands);
> +		((struct sctp_association *)asoc)->new_transport = NULL;
> +	}
> 
> 	return SCTP_DISPOSITION_CONSUME;
> }
> -- 
> 1.7.3.2
> 
> 

