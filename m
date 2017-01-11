From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v2] ipvlan: improvise dev_id generation logic in
 IPvlan
Date: Tue, 10 Jan 2017 20:47:41 -0500 (EST)
Message-ID: <20170110.204741.1506942846730150633.davem@davemloft.net>
References: <20170109230554.38328-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, edumazet@google.com,
        davem@davemloft.org
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932619AbdAKBrn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:47:43 -0500
In-Reply-To: <20170109230554.38328-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Mon,  9 Jan 2017 15:05:54 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> The patch 009146d117b ("ipvlan: assign unique dev-id for each slave
> device.") used ida_simple_get() to generate dev_ids assigned to the
> slave devices. However (Eric has pointed out that) there is a shortcoming
> with that approach as it always uses the first available ID. This
> becomes a problem when a slave gets deleted and a new slave gets added.
> The ID gets reassigned causing the new slave to get the same link-local
> address. This side-effect is undesirable.
> 
> This patch adds a per-port variable that keeps track of the IDs
> assigned and used as the stat-base for the IDR api. This base will be
> wrapped around when it reaches the MAX (0xFFFE) value possibly on a
> busy system where slaves are added and deleted routinely.
> 
> Fixes: 009146d117b ("ipvlan: assign unique dev-id for each slave device.")
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> CC: Eric Dumazet <edumazet@google.com>
> CC: David Miller <davem@davemloft.org>
> ---
> v1 -> v2
>   Implemented Dave's comments and reinstated IDR API.

Applied, thanks.
