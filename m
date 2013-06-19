From: Jason Wang <jasowang@redhat.com>
Subject: Re: qlen check in tun.c
Date: Wed, 19 Jun 2013 11:29:22 +0800
Message-ID: <51C12592.6050503@redhat.com>
References: <CAPshTCgdb9FzKHzxkpDpowZjzqBv5yM_rBpcT88YmYBSojN8Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933941Ab3FSD3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 23:29:37 -0400
In-Reply-To: <CAPshTCgdb9FzKHzxkpDpowZjzqBv5yM_rBpcT88YmYBSojN8Tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 10:31 AM, Jerry Chu wrote:
> In tun_net_xmit() the max qlen is computed as
> dev->tx_queue_len / tun->numqueues. For multi-queue configuration the
> latter may be way too small, forcing one to adjust txqueuelen based
> on number of queues created. (Well the default txqueuelen of
> 500/TUN_READQ_SIZE already seems too small even for single queue.)

Hi Jerry:

Do you have some test result of this? Anyway, tun allows userspace to
adjust this value based on its requirement.
>
> Wouldn't it be better to simply use dev->tx_queue_len to cap the qlen of
> each queue? This also seems to be more consistent with h/w multi-queues.

Make sense. Michael, any ideas on this?
>
> Also is there any objection to increase MAX_TAP_QUEUES from 8 to 16?
> Yes it will take up more space in struct tun_struct. But we are
> hitting the perf limit of 8 queues.

Not only the tun_struct, another issue of this is sizeof(netdev_queue)
which is 320 currently, if we use 16, it may be greater than 4096 which
lead high order page allocation. Need a solution such as flex array or
array of pointers.

Btw, I have draft patch on both, will post as rfc.

Thanks
> Thanks,
>
> Jerry
