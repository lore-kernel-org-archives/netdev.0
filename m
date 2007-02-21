From: "Jon Maloy \(QB/EMC\)" <jon.maloy@ericsson.com>
Subject: RE: [TIPC] Missing null check in the socket code.
Date: Wed, 21 Feb 2007 09:02:37 -0500
Message-ID: <6D19CA8D71C89C43A057926FE0D4ADAADCB6A2@ecamlmw720.eamcs.ericsson.se>
References: <1171607254637-git-send-email-maxk@qualcomm.com> <11716072541171-git-send-email-maxk@qualcomm.com> <45DB4280.6030102@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>
To: "Max Krasnyansky" <maxk@qualcomm.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr1.ericy.com ([198.24.6.9]:56889 "EHLO imr1.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030580AbXBUQhE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 11:37:04 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acknowledged. We'll deliver it along with 
some other patches ASAP.

///jon


-----Original Message-----
From: Max Krasnyansky [mailto:maxk@qualcomm.com]
Sent: Tue 2/20/2007 1:48 PM
To: davem@davemloft.net
Cc: netdev@vger.kernel.org; Jon Maloy (QB/EMC); allan.stephens@windriver.com
Subject: Re: [TIPC] Missing null check in the socket code.
 
Max Krasnyansky wrote:
> Fixes an oops in the non-blocking mode.
> 
> Signed-off-by: Max Krasnyansky <maxk@qualcomm.com>
> ---
>  net/tipc/socket.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 2a6a5a6..767f791 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -862,6 +862,10 @@ restart:
>  	/* Get access to first message in receive queue */
>  
>  	buf = skb_peek(&sock->sk->sk_receive_queue);
> +	if (NULL == buf) {
> +		res = -EAGAIN;
> +		goto exit;
> +	}
>  	msg = buf_msg(buf);
>  	sz = msg_data_sz(msg);
>  	err = msg_errcode(msg);

Just a reminder. Please apply.

Thanx
Max

