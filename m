From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3 1/2] inet_diag: allow protocols to provide
 additional data
Date: Tue, 29 Aug 2017 15:34:49 -0700
Message-ID: <20170829153449.5f2cfadb@xeon-e3>
References: <20170829222954.24863-1-colona@arista.com>
        <20170829222954.24863-2-colona@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33302 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751270AbdH2Wew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:34:52 -0400
Received: by mail-pf0-f169.google.com with SMTP id r62so14082024pfj.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 15:34:51 -0700 (PDT)
In-Reply-To: <20170829222954.24863-2-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Aug 2017 15:29:53 -0700
Ivan Delalande <colona@arista.com> wrote:

> @@ -452,13 +466,14 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
>  	struct net *net = sock_net(in_skb->sk);
>  	struct sk_buff *rep;
>  	struct sock *sk;
> +	bool net_admin = netlink_net_capable(in_skb, CAP_NET_ADMIN);

Please keep declarations in Christmas tree order if possible.

int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
		      struct user_namespace *user_ns,
		      u32 portid, u32 seq, u16 nlmsg_flags,
		      const struct nlmsghdr *unlh,
		      bool net_admin)
{
	bool net_admin = netlink_net_capable(in_skb, CAP_NET_ADMIN);
	const struct tcp_congestion_ops *ca_ops;
	const struct inet_diag_handler *handler;
	int ext = req->idiag_ext;
	struct inet_diag_msg *r;
	struct nlmsghdr  *nlh;
	struct nlattr *attr;
	void *info = NULL;
