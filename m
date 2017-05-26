From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sctp: fix ICMP processing if skb is non-linear
Date: Fri, 26 May 2017 14:42:29 -0400 (EDT)
Message-ID: <20170526.144229.378338079766962924.davem@davemloft.net>
References: <d0cd7c2e4b9329ec23e48aed94bf2fbf94554f44.1495730857.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        lucien.xin@gmail.com, marcelo.leitner@gmail.com
To: dcaratti@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756784AbdEZSmc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:42:32 -0400
In-Reply-To: <d0cd7c2e4b9329ec23e48aed94bf2fbf94554f44.1495730857.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>
Date: Thu, 25 May 2017 19:14:56 +0200

> sometimes ICMP replies to INIT chunks are ignored by the client, even if
> the encapsulated SCTP headers match an open socket. This happens when the
> ICMP packet is carried by a paged skb: use skb_header_pointer() to read
> packet contents beyond the SCTP header, so that chunk header and initiate
> tag are validated correctly.
> 
> v2:
> - don't use skb_header_pointer() to read the transport header, since
>   icmp_socket_deliver() already puts these 8 bytes in the linear area.
> - change commit message to make specific reference to INIT chunks.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Applied and queued up for -stable, thanks.
