From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [RFC 6/8] NetLabel: CIPSOv4 integration
Date: Fri, 28 Jul 2006 07:54:30 -0400
Message-ID: <1154087670.5165.36.camel@jzny2>
References: <20060622224910.885573000@flek.zko.hp.com>
	 <20060622225410.521216000@flek.zko.hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:17108 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1161127AbWG1Lyc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 07:54:32 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G6QvK-000224-QK
	for netdev@vger.kernel.org; Fri, 28 Jul 2006 07:54:34 -0400
To: paul.moore@hp.com
In-Reply-To: <20060622225410.521216000@flek.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-22-06 at 18:49 -0400, paul.moore@hp.com wrote:
> plain text document attachment (netlabel-cipsov4)
> Add CIPSO/IPv4 support and management to the NetLabel subsystem.  These changes
> integrate the CIPSO/IPv4 configuration into the existing NetLabel code and
> enable the use of CIPSO/IPv4 within the overall NetLabel framework.
> ---
>  net/netlabel/netlabel_cipso_v4.c |  583 +++++++++++++++++++++++++++++++++++++++
>  1 files changed, 583 insertions(+)
> 

> +/**
> + * netlbl_cipsov4_rcv - Process incoming NetLabel packets
> + * @skb: the NETLINK buffer
> + * @msg: pointer to the start of the NetLabel data
> + *
> + * Description:
> + * This function is reponsibile for reading all of the incoming CIPSO V4
> + * NetLabel traffic and dispatching it to the correct CIPSO V4 functions.
> + *
> + */
> +void netlbl_cipsov4_rcv(const struct sk_buff *skb, const unsigned char *msg)
> +{
> +	int ret_val;
> +	struct netlbl_cipsov4_msghdr *nl_cv4_hdr;
> +
> +	if (nlmsg_len((struct nlmsghdr *)skb->data) <
> +	    sizeof(struct netlbl_cipsov4_msghdr)) {
> +		netlbl_cipsov4_send_ack(skb, EINVAL);
> +		return;
> +	}
> +
> +	nl_cv4_hdr = (struct netlbl_cipsov4_msghdr *)msg;
> +	switch (nl_cv4_hdr->opcode) {
> +	case NL_CV4_ADD:

Could you not have had all these NL_CV4_CMDs as just TLVs?
This is just the classical way of how we do things.
This would allow you to send multiple cmds in one message as well as 
very easily add new ones in the future.

BTW, can you please repost your latest changes to netdev?

cheers,
jamal

