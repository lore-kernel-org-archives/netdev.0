From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
Date: Thu, 16 Jan 2014 12:23:01 +0800
Message-ID: <52D75EA5.1050000@redhat.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com,
	davem@davemloft.net, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56858 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbaAPEXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 23:23:11 -0500
In-Reply-To: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2014 10:20 PM, Zhi Yong Wu wrote:
> From: Zhi Yong Wu<wuzhy@linux.vnet.ibm.com>
>
> HI, folks
>
> The patchset is trying to integrate aRFS support to virtio_net. In this case,
> aRFS will be used to select the RX queue. To make sure that it's going ahead
> in the correct direction, although it is still one RFC and isn't tested, it's
> post out ASAP. Any comment are appreciated, thanks.
>
> If anyone is interested in playing with it, you can get this patchset from my
> dev git on github:
>    git://github.com/wuzhy/kernel.git virtnet_rfs
>
> Zhi Yong Wu (3):
>    virtio_pci: Introduce one new config api vp_get_vq_irq()
>    virtio_net: Introduce one dummy function virtnet_filter_rfs()
>    virtio-net: Add accelerated RFS support
>
>   drivers/net/virtio_net.c      |   67 ++++++++++++++++++++++++++++++++++++++++-
>   drivers/virtio/virtio_pci.c   |   11 +++++++
>   include/linux/virtio_config.h |   12 +++++++
>   3 files changed, 89 insertions(+), 1 deletions(-)
>

Please run get_maintainter.pl before sending the patch. You'd better at 
least cc virtio maintainer/list for this.

The core aRFS method is a noop in this RFC which make this series no 
much sense to discuss. You should at least mention the big picture here 
in the cover letter. I suggest you should post a RFC which can run and 
has expected result or you can just raise a thread for the design 
discussion.

And this method has been discussed before, you can search "[net-next RFC 
PATCH 5/5] virtio-net: flow director support" in netdev archive for a 
very old prototype implemented by me. It can work and looks like most of 
this RFC have already done there.

A basic question is whether or not we need this, not all the mq cards 
use aRFS (see ixgbe ATR). And whether or not it can bring extra 
overheads? For virtio, we want to reduce the vmexits as much as possible 
but this aRFS seems introduce a lot of more of this. Making a complex 
interfaces just for an virtual device may not be good, simple method may 
works for most of the cases.

We really should consider to offload this to real nic. VMDq and L2 
forwarding offload may help in this case.
