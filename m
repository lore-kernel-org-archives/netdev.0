From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC v2] netlink: add NETLINK_CAP_ACK socket option
Date: Wed, 26 Aug 2015 09:46:49 +0200
Message-ID: <20150826094649.0f9e3ac6@griffin>
References: <1440531809-26963-1-git-send-email-christophe-h.ricard@st.com>
	<1440531809-26963-2-git-send-email-christophe-h.ricard@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, sfeldma@gmail.com, sameo@linux.intel.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	Christophe Ricard <christophe-h.ricard@st.com>,
	stable@vger.kernel.org
To: Christophe Ricard <christophe.ricard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50217 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756635AbbHZHqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 03:46:54 -0400
In-Reply-To: <1440531809-26963-2-git-send-email-christophe-h.ricard@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2015 21:43:29 +0200, Christophe Ricard wrote:
>  void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
>  {
> +	struct netlink_sock *nlk;
>  	struct sk_buff *skb;
>  	struct nlmsghdr *rep;
>  	struct nlmsgerr *errmsg;
>  	size_t payload = sizeof(*errmsg);
> +	struct sock *sk;
>  
> -	/* error messages get the original request appened */
> -	if (err)
> +	sk = netlink_lookup(sock_net(in_skb->sk),
> +			    in_skb->sk->sk_protocol,
> +			    NETLINK_CB(in_skb).portid);

The necessity to look up the socket for every ack was what I didn't
like about this. Would it be possible to add a socket parameter to
various code paths that lead to netlink_ack (or a boolean, as David
suggested)? It will probably be needed to add it to
netlink_sock->netlink_rcv, netlink_kernel_cfg->input, etc.

As an alternative, David also suggested to attach the sender socket to
in_skb->sk. Could work, too.

Thanks,

 Jiri

-- 
Jiri Benc
