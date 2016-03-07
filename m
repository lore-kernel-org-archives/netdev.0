From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Mon, 7 Mar 2016 13:28:15 -0800
Message-ID: <20160307212815.GA5613@kafai-mba.gkf168.com>
References: <1456946361-9889-1-git-send-email-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50871 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753589AbcCGV2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 16:28:30 -0500
Content-Disposition: inline
In-Reply-To: <1456946361-9889-1-git-send-email-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2016 at 11:19:21AM -0800, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
>
> When ICMPV6_PKT_TOOBIG message is received by a connected UDP socket,
> the new mtu value is not properly updated in the dst_entry associated
> with the socket.
> This leads to the issue that the mtu value returned by getsockopt(sockfd,
> IPPROTO_IPV6, IPV6_MTU, ...) is wrong.
> The fix is to call the corresponding pmtu related function for connected
> socket so that the dst_entry associated with the socket will get updated
> with the new mtu value.
Would it be a better fix if ip6_sk_update_pmtu() does a dst_check() and
updates sk->sk_dst_cache (if needed) before it returns?  It seems
ipv4_sk_update_pmtu() is also doing it.

or

sk->sk_dst_cache is still valid after ip6_sk_update_pmtu() returns?
