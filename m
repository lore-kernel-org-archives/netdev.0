From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 4/4] ibmveth: Add support for Large Receive
 Offload
Date: Mon, 27 Apr 2015 17:10:12 -0700
Message-ID: <1430179812.22254.240.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430172655-17606-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
	 <1430172655-17606-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	nfont@linux.vnet.ibm.com, Brian King <brking@linux.vnet.ibm.com>
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:36344 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbbD1AZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 20:25:07 -0400
Received: by iebrs15 with SMTP id rs15so6945230ieb.3
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 17:25:06 -0700 (PDT)
In-Reply-To: <1430172655-17606-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-04-27 at 17:10 -0500, Thomas Falcon wrote:




> +				if (be16_to_cpu(skb->protocol) == ETH_P_IP) {
> +					skb_set_network_header(skb, 0);
> +					skb_set_transport_header(skb, sizeof(struct iphdr));
> +					iph = ip_hdr(skb);
> +

All this should really be :

if (skb->protocol == htons(ETH_P_IP)) {
	iph = (struct iphdr *)skb->data;

Because setting network header and a (potentially wrong) transport
header is confusing at this stage.

(It should be done later in core networking stack)
