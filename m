From: Philipp Zabel <philipp.zabel@gmail.com>
Subject: Re: [PATCH] net/irda: add clk_prepare/clk_unprepare to pxaficp_ir
Date: Sat, 17 Mar 2012 11:43:09 +0100
Message-ID: <CA+gwMceyQcfs-xM6+PB79uPOBNPKJ5fER=DjDPpmdqS5OcnTXA@mail.gmail.com>
References: <1331835569.14662.11.camel@flow>
	<20120316.231047.1919840752101978309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, eric.y.miao@gmail.com,
	haojian.zhuang@marvell.com, samuel@sortiz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:38464 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756743Ab2CQKnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 06:43:09 -0400
Received: by obbeh20 with SMTP id eh20so133013obb.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 03:43:09 -0700 (PDT)
In-Reply-To: <20120316.231047.1919840752101978309.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 17, 2012 at 7:10 AM, David Miller <davem@davemloft.net> wrote:
> From: Philipp Zabel <philipp.zabel@gmail.com>
> Date: Thu, 15 Mar 2012 19:19:29 +0100
>
>> This patch adds clk_prepare/clk_unprepare calls to the pxaficp_ir
>> driver by using the helper functions clk_prepare_enable and
>> clk_disable_unprepare.
>>
>> Signed-off-by: Philipp Zabel <philipp.zabel@gmail.com>
>
> This is terrible.
>
> So the problem was that clk_enable can't be invoked from atomic
> context, because it wants to take a mutex for some implementation.
>
> Therefore an existing routine with well defined semantics,
> clk_enable(), was turned into a NOP.
>
> And this silently breaks drivers.
>
> Instead of silently breaking things, make direct
> clk_enable()/clk_disable() invocations either result in a compile
> error or a run-time BUG_ON().

I expect that anybody who turns clk_enable/clk_disable into
no-ops for their platform will be sensible enough to take care of this.
The common struct clk framework already keeps a prepare_count
variable and clk_enable does WARN_ON(clk->prepare_count == 0).

In case of PXA, it's the clk_prepare/clk_unprepare calls that are the
no-ops anyway, so thanks for applying.

regards
Philipp
