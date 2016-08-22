From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: gre: Use the consitent GRE and PPTP
 struct instead of the structures defined in netfilter
Date: Mon, 22 Aug 2016 11:22:09 +0200
Message-ID: <20160822092209.GA2810@salvia>
References: <1471618894-10582-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
        philipp@redfish-solutions.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45928 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752648AbcHVJWR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 05:22:17 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7A89DE9771
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 11:22:14 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6B1CE100A40
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 11:22:14 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 79AE3FF153
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 11:22:10 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1471618894-10582-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 11:01:34PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> There are two structures which define the GRE header and PPTP
> header. So it is unneccessary to define duplicated structures in
> netfilter again.

Please, split this change in smaller patches, I'd suggest one to
replace GRE_* definitions and another to use generic GRE struct
definitions, so this makes it is easier to review.

> @@ -212,8 +212,8 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
>  	if (!pgrehdr)
>  		return true;
>  
> -	if (ntohs(grehdr->protocol) != GRE_PROTOCOL_PPTP) {
> -		pr_debug("GRE_VERSION_PPTP but unknown proto\n");
> +	if (grehdr->protocol != GRE_PROTO_PPP) {
> +		pr_debug("Unknown GRE proto(0x%x)\n", ntohs(grehdr->protocol));

Something is fishy here, grehdr->protocol used to have ntohs(), the
pr_debug() still has it while the branch check does not.
