From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Fix kernel panic while received AUTH chunk while
 enabled auth
Date: Fri, 25 Jan 2008 11:41:17 -0500
Message-ID: <479A112D.5020201@hp.com>
References: <4794C51B.8040904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:17551 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbYAYQlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 11:41:19 -0500
In-Reply-To: <4794C51B.8040904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the delay.  Was on vacation without net access.

Wei Yongjun wrote:
> 
> 
> This patch fix this probleam to treat AUTH chunk as unknow chunk if peer 
> has initialized with no auth capable.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

> 
> --- a/net/sctp/sm_statefuns.c    2008-01-21 00:03:25.000000000 -0500
> +++ b/net/sctp/sm_statefuns.c    2008-01-21 05:14:08.000000000 -0500
> @@ -3785,6 +3785,10 @@ sctp_disposition_t sctp_sf_eat_auth(cons
>     struct sctp_chunk *err_chunk;
>     sctp_ierror_t error;
> 
> +    /* Make sure that the peer has AUTH capable */
> +    if (!asoc->peer.auth_capable)
> +        return sctp_sf_unk_chunk(ep, asoc, type, arg, commands);
> +
>     if (!sctp_vtag_verify(chunk, asoc)) {
>         sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
>                 SCTP_NULL());
> 
> 
> 

