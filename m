From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Vpn-failover] [RFC] IPSEC failover - Netlink part
Date: Mon, 08 Nov 2004 17:10:24 +0100
Message-ID: <418F9A70.7040400@trash.net>
References: <1099045435.2888.47.camel@nienna.balabit> <418A3630.1040900@astaro.de> <418A71DA.2090607@trash.net> <418F4AF9.7050605@astaro.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vpn-failover@lists.balabit.hu, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Ulrich Weber <uweber@astaro.de>
In-Reply-To: <418F4AF9.7050605@astaro.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ulrich Weber wrote:

> what did you mean with "leaks xfrm_state reference"? The missing
> xfrm_state_put(x) ?

Yes.

> I changed it (see below) to use Krisztian's xfrm_state_replay_update 
> function.

Even better.

> |> static const int xfrm_msg_min[(XFRM_MSG_MAX + 1 - XFRM_MSG_BASE)] = {
> |>     NLMSG_LENGTH(sizeof(struct xfrm_usersa_info)),    /* NEW SA */
> |>     NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),    /* DEL SA */
> |> @@ -867,6 +897,7 @@
> |>     NLMSG_LENGTH(sizeof(struct xfrm_user_polexpire)), /* POLEXPIRE */
> |>     NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush)),    /* FLUSH SA */
> |>     NLMSG_LENGTH(0),                /* FLUSH POLICY */
> |> +    NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),/* UPD SEQ */
> |>
> |>
> | ^^ what about struct xfrm_replay_state ?
> it's attached as rt attribute, so it should be ok.


But you don't check it's size. You need to include it here or check it
when you use it.

Regards
Patrick
