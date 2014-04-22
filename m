From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next 1/3] net: ipv6: unduplicate {raw,udp}v6_sendmsg
 code
Date: Tue, 22 Apr 2014 18:06:39 +0900
Message-ID: <5356311F.6080901@linux-ipv6.org>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, davem@davemloft.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:52487 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754015AbaDVJGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 05:06:42 -0400
In-Reply-To: <1398154415-24486-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lorenzo Colitti wrote:
> rawv6_sendmsg and udpv6_sendmsg have ~100 lines of almost
> identical code. Move this into a new ipv6_datagram_send_common
> helper function.
> 
> Tested: black-box tested using user-mode Linux.
> 
> - Basic UDP sends using sendto work.
> - Mark routing and oif routing using SO_BINDTODEVICE work.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  include/net/ipv6.h  |   7 +++
>  net/ipv6/datagram.c | 131 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/raw.c      | 107 ++++--------------------------------------
>  net/ipv6/udp.c      | 117 ++++------------------------------------------
>  4 files changed, 154 insertions(+), 208 deletions(-)
> 
:
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -915,6 +915,137 @@ exit_f:
>  }
>  EXPORT_SYMBOL_GPL(ip6_datagram_send_ctl);
>  
> +int ip6_datagram_send_common(struct sock *sk, struct msghdr *msg,
> +			     struct sockaddr_in6 *sin6, int addr_len,
> +			     struct flowi6 *fl6, struct dst_entry **dstp,
> +			     struct ipv6_txoptions **optp,
> +			     struct ipv6_txoptions *opt_space,
> +			     int *hlimit, int *tclass, int *dontfrag,
> +			     int *connected) {

Put this opening brace at the beginning of the next line, please.

--yoshfuji
