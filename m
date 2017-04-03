From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: check for dst and pathmtu update in
 sctp_packet_config
Date: Mon, 03 Apr 2017 15:01:30 -0700 (PDT)
Message-ID: <20170403.150130.1161020461020101697.davem@davemloft.net>
References: <7d69e45b3cc8f84658e04ab07288a9fe09254e12.1491038159.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50632 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751479AbdDCWBb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 18:01:31 -0400
In-Reply-To: <7d69e45b3cc8f84658e04ab07288a9fe09254e12.1491038159.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat,  1 Apr 2017 17:15:59 +0800

> This patch is to move sctp_transport_dst_check into sctp_packet_config
> from sctp_packet_transmit and add pathmtu check in sctp_packet_config.
> 
> With this fix, sctp can update dst or pathmtu before appending chunks,
> which can void dropping packets in sctp_packet_transmit when dst is
> obsolete or dst's mtu is changed.
> 
> This patch is also to improve some other codes in sctp_packet_config.
> It updates packet max_size with gso_max_size, checks for dst and
> pathmtu, and appends ecne chunk only when packet is empty and asoc
> is not NULL.
> 
> It makes sctp flush work better, as we only need to set up them once
> for one flush schedule. It's also safe, since asoc is NULL only when
> the packet is created by sctp_ootb_pkt_new in which it just gets the
> new dst, no need to do more things for it other than set packet with
> transport's pathmtu.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks Xin.
