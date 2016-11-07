From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 06/11] net: l3mdev: remove redundant calls
Date: Mon, 7 Nov 2016 08:48:53 -0700
Message-ID: <0eb5f56b-80dd-0c91-0adb-a91736bbc3f5@cumulusnetworks.com>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
 <1473534602-23602-7-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr21aQnjyrb6P7aThvnhNLaJt-yrFsyokUBCyOJZkKXwJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        shm@cumulusnetworks.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:36683 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753223AbcKGPtI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 10:49:08 -0500
Received: by mail-it0-f50.google.com with SMTP id q124so31130155itd.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 07:49:08 -0800 (PST)
In-Reply-To: <CAKD1Yr21aQnjyrb6P7aThvnhNLaJt-yrFsyokUBCyOJZkKXwJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/7/16 3:13 AM, Lorenzo Colitti wrote:
> What should we do here? It would seem that now that
> netif_index_is_l3_master has been resurrected, it's appropriate to use
> it here as well. The user-visible behaviour changed only two months
> ago. Unless we think that RSTs should always mirror the iif, in which
> case I can change our tests accordingly.

Using ingress information (iif in this case) to determine the route for a response seems appropriate.

I can send a patch to revert back to:

	if (!oif && netif_index_is_vrf(net, skb->skb_iif))
		oif = skb->skb_iif;

thanks for the report.
