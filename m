From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: fix call to SCTP_CMD_PROCESS_SACK in sctp_cmd_interpreter()
Date: Mon, 15 Oct 2012 11:40:38 -0400
Message-ID: <507C2E76.3030801@gmail.com>
References: <1350309399-23422-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Zijie Pan <zijie.pan@6wind.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:43264 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab2JOPkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 11:40:42 -0400
In-Reply-To: <1350309399-23422-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/2012 09:56 AM, nicolas.dichtel@6wind.com wrote:
> From: Zijie Pan <zijie.pan@6wind.com>
>
> Bug introduced by commit edfee0339e681a784ebacec7e8c2dc97dc6d2839
> (sctp: check src addr when processing SACK to update transport state)
>
> Signed-off-by: Zijie Pan <zijie.pan@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Shutdown case..  ACK.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>


> ---
>   net/sctp/sm_sideeffect.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 57f7de8..6773d78 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -1642,8 +1642,9 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>   					asoc->outqueue.outstanding_bytes;
>   			sackh.num_gap_ack_blocks = 0;
>   			sackh.num_dup_tsns = 0;
> +			chunk->subh.sack_hdr = &sackh;
>   			sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_SACK,
> -					SCTP_SACKH(&sackh));
> +					SCTP_CHUNK(chunk));
>   			break;
>
>   		case SCTP_CMD_DISCARD_PACKET:
>
