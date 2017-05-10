From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: Re: DQL and TCQ_F_CAN_BYPASS destroy performance under virtualizaiton
 (Was: "Re: net_sched strange in 4.11")
Date: Wed, 10 May 2017 06:35:39 +0100
Message-ID: <4dbbeb14-8036-ab95-1dc0-f4090c858099@cambridgegreys.com>
References: <66c5c2d3-65df-8506-6934-5628e709e229@cambridgegreys.com>
 <27ae4e1c-7c6c-14c2-f3a4-9d0b1265d034@cambridgegreys.com>
 <20170509151109.GH16825@stefanha-x1.localdomain>
 <52801b17-d8af-eaba-3ecf-fa4495c352f5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:41083 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbdEJFfw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 01:35:52 -0400
In-Reply-To: <52801b17-d8af-eaba-3ecf-fa4495c352f5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

> Virtio-net net does not support BQL. Before commit ea7735d97ba9
> ("virtio-net: move free_old_xmit_skbs"), it's even impossible to
> support that since we don't have tx interrupt for each packet.  I
> haven't measured the impact of xmit_more, maybe I was wrong but I
> think it may help in some cases since it may improve the batching on
> host more or less.

Sorry, hit send too soon.

Impact of xmit more depends on your transport.

If, for example, you are using sendmmsg on the outer side which can
consume the bulked data "as is", the impact is quite significant. If
your transport does not support bulking, the fact there was bulking
earlier in the chain has little impact.

There is some, but not a lot.

[snip]

-- 
Anton R. Ivanov
Cambridgegreys Limited. Registered in England. Company Number 10273661
