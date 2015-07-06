From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Add counters for out data chunk discards
Date: Mon, 06 Jul 2015 14:46:32 -0400
Message-ID: <559ACD08.1080902@gmail.com>
References: <1436204245-21645-1-git-send-email-vitalya@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Vitaly Andrianov <vitalya@ti.com>, nhorman@tuxdriver.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436204245-21645-1-git-send-email-vitalya@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/06/2015 01:37 PM, Vitaly Andrianov wrote:
> This commit adds a MIB entry for out data chunk discards.
> Number of outgoing SCTP DATA chunks for a SCTP association for which no
> problems were encountered to prevent their transmission but were discarded.
> Data chunks are discarded due to ungraceful closing of the SCTP
> association.
> 
> Signed-off-by: Vitaly Andrianov <vitalya@ti.com>
> ---
>  include/net/sctp/sctp.h | 1 +
>  net/sctp/outqueue.c     | 1 +
>  net/sctp/proc.c         | 2 ++
>  3 files changed, 4 insertions(+)
> 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index ce13cf2..fd806ea 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -216,6 +216,7 @@ enum {
>  	SCTP_MIB_IN_PKT_BACKLOG,
>  	SCTP_MIB_IN_PKT_DISCARDS,
>  	SCTP_MIB_IN_DATA_CHUNK_DISCARDS,
> +	SCTP_MIB_OUT_DATA_CHUNK_DISCARDS,
>  	__SCTP_MIB_MAX
>  };
>  
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 7e8f0a1..dc1a40f 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -315,6 +315,7 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
>  		case SCTP_STATE_SHUTDOWN_RECEIVED:
>  		case SCTP_STATE_SHUTDOWN_ACK_SENT:
>  			/* Cannot send after transport endpoint shutdown */
> +			SCTP_INC_STATS(net, SCTP_MIB_OUT_DATA_CHUNK_DISCARDS);
>  			error = -ESHUTDOWN;
>  			break;

First, this is not the only case where a chunk is discarded on output.  If you
are going to add an OUT_DATA_DISCARDS counter, you need to catch all such discards.
Second,  in this particular case, you will count discarded messages, not chunks since
sctp_outq_tail is guaranteed to queue the whole message or none of it.

-vlad

>  
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 0697eda..1a10b81 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -67,6 +67,8 @@ static const struct snmp_mib sctp_snmp_list[] = {
>  	SNMP_MIB_ITEM("SctpInPktBacklog", SCTP_MIB_IN_PKT_BACKLOG),
>  	SNMP_MIB_ITEM("SctpInPktDiscards", SCTP_MIB_IN_PKT_DISCARDS),
>  	SNMP_MIB_ITEM("SctpInDataChunkDiscards", SCTP_MIB_IN_DATA_CHUNK_DISCARDS),
> +	SNMP_MIB_ITEM("SctpOutDataChunkDiscards",
> +		      SCTP_MIB_OUT_DATA_CHUNK_DISCARDS),
>  	SNMP_MIB_SENTINEL
>  };
>  
> 
