From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/12] net/mlx5e: Poll rx cq before tx cq to
 improve round-trip latency
Date: Mon, 22 Jun 2015 06:35:54 -0700 (PDT)
Message-ID: <20150622.063554.1081040359354241131.davem@davemloft.net>
References: <1434554789-13758-6-git-send-email-ogerlitz@mellanox.com>
	<20150621.102144.267706734504980452.davem@davemloft.net>
	<CAEHy93LdUDFVoxWU_++t1D5tqBSEM1TY4ZguW7QszvEyPOvagg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com,
	talal@mellanox.com, saeedm@mellanox.com
To: achiad.mellanox@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbbFVNYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 09:24:10 -0400
In-Reply-To: <CAEHy93LdUDFVoxWU_++t1D5tqBSEM1TY4ZguW7QszvEyPOvagg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: achiad shochat <achiad.mellanox@gmail.com>
Date: Mon, 22 Jun 2015 00:35:37 +0300

> Hello Dave,
> 
> In mlx5 the RX processing is broken down into two stages:
> 1) Hand to kernel SKBs of completed RX packets - @mlx5e_poll_rx_cq()
> 2) Allocate and post to HW new RX buffers - @mlx5e_post_rx_wqes()
> 
> Would handling of TX completions in between stages (1) and (2) be OK?

I would do all of TX processing first and synchronously.  It's very
cheap and makes lots of resources available for RX processing.
