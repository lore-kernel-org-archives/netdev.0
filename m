From: achiad shochat <achiad.mellanox@gmail.com>
Subject: Re: [PATCH net-next 05/12] net/mlx5e: Poll rx cq before tx cq to
 improve round-trip latency
Date: Mon, 22 Jun 2015 00:35:37 +0300
Message-ID: <CAEHy93LdUDFVoxWU_++t1D5tqBSEM1TY4ZguW7QszvEyPOvagg@mail.gmail.com>
References: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
	<1434554789-13758-6-git-send-email-ogerlitz@mellanox.com>
	<20150621.102144.267706734504980452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com,
	talal@mellanox.com, saeedm@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36586 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbbFUVfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 17:35:38 -0400
Received: by oigb199 with SMTP id b199so68594574oig.3
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 14:35:37 -0700 (PDT)
In-Reply-To: <20150621.102144.267706734504980452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

In mlx5 the RX processing is broken down into two stages:
1) Hand to kernel SKBs of completed RX packets - @mlx5e_poll_rx_cq()
2) Allocate and post to HW new RX buffers - @mlx5e_post_rx_wqes()

Would handling of TX completions in between stages (1) and (2) be OK?

On 21 June 2015 at 20:21, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Wed, 17 Jun 2015 18:26:22 +0300
>
>> From: Achiad Shochat <achiad@mellanox.com>
>>
>> For better round trip latency, handle rx completions before
>> tx completions.
>>
>> Signed-off-by: Achiad Shochat <achiad@mellanox.com>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>
> I completely disagree with this change.
>
> TX completions should always be handled first because they free up resources
> and therefore increase the likelyhood that RX processing will not fail due
> to lack of resources (memory, etc.).
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
