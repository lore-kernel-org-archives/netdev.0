From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sunvnet: don't change gso data on clones
Date: Wed, 11 Feb 2015 05:56:33 -0800
Message-ID: <1423662993.4847.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54DB5711.3040705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:43795 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbbBKN4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 08:56:35 -0500
Received: by pdev10 with SMTP id v10so4489064pde.10
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 05:56:35 -0800 (PST)
In-Reply-To: <54DB5711.3040705@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-11 at 08:20 -0500, David L Stevens wrote:
> This patch unclones an skb for the case where the sunvnet driver needs to
> change the segmentation size so that it doesn't interfere with TCP SACK's
> use of them.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>
> ---

Hmm... this would point to a TCP bug ?

What happens if not GSO is needed, TCP corrupts data currently
read/processed by NIC/driver ?

TCP should have required skb_unclone() where needed.
