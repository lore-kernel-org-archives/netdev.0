From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 1/4] gtp: move TEID hash to per socket structure
Date: Tue, 14 Mar 2017 12:33:00 +0100
Message-ID: <20170314113300.GA2992@salvia>
References: <20170314112548.24027-1-aschultz@tpip.net>
 <20170314112548.24027-2-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>,
        osmocom-net-gprs@lists.osmocom.org,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33074 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751064AbdCNLdV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 07:33:21 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F063824623
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 12:33:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DDDC1DA873
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 12:33:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id ED3B4DA86F
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 12:33:04 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170314112548.24027-2-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 12:25:45PM +0100, Andreas Schultz wrote:
> @@ -275,9 +280,9 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
>  
>  	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
>  
> -	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
> +	pctx = gtp1_pdp_find(gsk, ntohl(gtp1->tid));
>  	if (!pctx) {
> -		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
> +		pr_debug("No PDP ctx to decap skb=%p\n", skb);
>  		return 1;

Again the pr_debug() change has resurrected.

I already told you: If we are going to have more than one gtp device,
then this doesn't make sense. I have to repeat things over and over
again, just because you don't want to rebase your patchset for some
reason. I don't find any other explaination for this.

So please remove this debugging rather than rendering this completely
useful.

Moreover this change has nothing to this patch, so this doesn't break
the one logical change per patch.
