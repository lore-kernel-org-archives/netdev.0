From: Philby John <pjohn@in.mvista.com>
Subject: Re: can we reuse an skb
Date: Mon, 22 Jun 2009 19:04:14 +0530
Message-ID: <1245677654.4541.37.camel@localhost.localdomain>
References: <b9e8fcbd0906190311k1db4653bm1d560743faa4ded1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Peter Chacko <peterchacko35@gmail.com>, jon_zhou@agilent.com,
	radhamohan_ch@yahoo.com, netdev@vger.kernel.org
To: Nicholas Van Orton <turanammo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:31368 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750958AbZFVNeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2009 09:34:14 -0400
In-Reply-To: <b9e8fcbd0906190311k1db4653bm1d560743faa4ded1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-06-19 at 15:41 +0530, Nicholas Van Orton wrote:
> Does this mean that when skb buffer has been allocated using
> dev_alloc_skb(), filled with received data and passed to the upper
> layers
> the kernel would automatically do the task of releasing this buffer
> without the user calling dev_kfree_skb()?

Yes, I think that is the case. Except when the user calls an ioctl that
closes your ethernet device, by say using $ifconfig eth0 down, in which
case you must free the ring skb buffer's allocated using
dev_kfree_skb().

>  I once got
> KERNEL: assertion (!atomic_read(&skb->users)) failed at net/core/dev.c
> errors when trying
> to free them using dev_kfree_skb()
> 
> Could this be cause I did not wait until netif_rx_completed() was called?

You are using an old version of the kernel, can't see such code in
2.6.30. From what I know, this usually happens if skb->users is not
equal to one, which means the buffer is in use by some user. Like I
said, you needn't call dev_kfree_skb() explicitly, it will be freed
after use by the upper network layers.

netif_receive_skb() ->deliver_skb()-> pt_prev->func() ->
ip_rcv() -> ip_rcv_finish()

ip_rcv_finish() would finally free it as per the specified protocol.
This I think is the flow, but I guess there would be experts here who
would correct me if I am wrong.

-Philby

