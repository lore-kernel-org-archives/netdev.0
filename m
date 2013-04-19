From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Fri, 19 Apr 2013 15:22:38 -0300
Message-ID: <CAOMZO5A_NdKJk7a7svTdB2-FzijwBoawfiM+TC8kuBmL06UsBQ@mail.gmail.com>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:46359 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab3DSSWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:22:39 -0400
Received: by mail-vb0-f52.google.com with SMTP id w8so3983614vbf.11
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 11:22:39 -0700 (PDT)
In-Reply-To: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lucas,

On Fri, Apr 19, 2013 at 11:36 AM, Lucas Stach <l.stach@pengutronix.de> wrote:
> Those patches introduce instability to the point of kernel OOPSes with
> NULL-ptr dereferences.
>
> The patches drop locks from the code without justifying why this would
> be safe at all. In fact it isn't safe as now the controller restart can
> happily free the RX and TX ring buffers while the NAPI poll function is
> still accessing them. So with a heavily loaded but slightly instable
> link we regularly end up with OOPSes because link change restarts
> the FEC and bombs away buffers still in use.

Can you please let us know how to reproduce the oopses? Which SoC did
you use in your tests?
