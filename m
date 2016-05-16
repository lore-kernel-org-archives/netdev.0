From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [tipc-discussion] [PATCH net-next] tipc: check nl sock before
	parsing nested attributes
Date: Mon, 16 May 2016 14:06:08 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D224888AF@eusaamb103.ericsson.se>
References: <1463390094-9235-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sploving1@gmail.com" <sploving1@gmail.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Richard Alpe <richard.alpe@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usplmg21.ericsson.net ([198.24.6.65]:51761 "EHLO
	usplmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbcEPOGL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 10:06:11 -0400
In-Reply-To: <1463390094-9235-1-git-send-email-richard.alpe@ericsson.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a serious bug, so it should be posted to net, not net-next.

Otherwise,
Acked-by: Jon Maloy <jon.maloy@ericsson.cm>

///jon

> -----Original Message-----
> From: Richard Alpe [mailto:richard.alpe@ericsson.com]
> Sent: Monday, 16 May, 2016 05:15
> To: netdev@vger.kernel.org
> Cc: sploving1@gmail.com; tipc-discussion@lists.sourceforge.net;
> eric.dumazet@gmail.com
> Subject: [tipc-discussion] [PATCH net-next] tipc: check nl sock before parsing
> nested attributes
> 
> Make sure the socket for which the user is listing publication exists
> before parsing the socket netlink attributes.
> 
> Prior to this patch a call without any socket caused a NULL pointer
> dereference in tipc_nl_publ_dump().
> 
> Tested-and-reported-by: Baozeng Ding <sploving1@gmail.com>
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> ---
>  net/tipc/socket.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 1262889..3b7a799 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -2853,6 +2853,9 @@ int tipc_nl_publ_dump(struct sk_buff *skb, struct
> netlink_callback *cb)
>  		if (err)
>  			return err;
> 
> +		if (!attrs[TIPC_NLA_SOCK])
> +			return -EINVAL;
> +
>  		err = nla_parse_nested(sock, TIPC_NLA_SOCK_MAX,
>  				       attrs[TIPC_NLA_SOCK],
>  				       tipc_nl_sock_policy);
> --
> 2.1.4
> 
> 
> ------------------------------------------------------------------------------
> Mobile security can be enabling, not merely restricting. Employees who
> bring their own devices (BYOD) to work are irked by the imposition of MDM
> restrictions. Mobile Device Manager Plus allows you to control only the
> apps on BYO-devices by containerizing them, leaving personal data untouched!
> https://ad.doubleclick.net/ddm/clk/304595813;131938128;j
> _______________________________________________
> tipc-discussion mailing list
> tipc-discussion@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/tipc-discussion
