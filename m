From: "Merav Sicron" <meravs@broadcom.com>
Subject: Re: UDP ordering when using multiple rx queue
Date: Wed, 11 Jul 2012 14:08:59 +0300
Message-ID: <1342004939.27284.28.camel@lb-tlvb-meravs.il.broadcom.com>
References: <CAL8zT=g5nHd6FprhxFc21XTgfXeaokt4QN1fS4ekcNVkuvZE9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Jean-Michel Hautbois" <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4788 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642Ab2GKLKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 07:10:21 -0400
In-Reply-To: <CAL8zT=g5nHd6FprhxFc21XTgfXeaokt4QN1fS4ekcNVkuvZE9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 00:53 -0700, Jean-Michel Hautbois wrote:

> Several tests lead to a simple conclusion : when the NIC has only one
> RX queue, everything is ok (like be2net for instance), but when it has
> more than one RX queue, then I can have "lost packets".
> This is the case for bnx2x or mlx4 for instance.
>From what you describe I assume that you use different source IP /
destination IP in each packet - is this something that you can control?
Because with the same IP addresses the traffic will be steered to the
same queue. 

> Here are my questions :
> - Is it possible to force a driver to use only one rx queue, even if
> it can use more without reloading the driver (and this is feasible
> only when a parameter exists for that !) ?
You can reduce the number of queues using "ethtool -L ethX combined 1".
Note however that it will cause automatic driver unload/load.

Thanks,
Merav
