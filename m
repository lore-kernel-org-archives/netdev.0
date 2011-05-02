From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: Byte queue limit patch series
Date: Sun, 01 May 2011 20:49:38 -0700 (PDT)
Message-ID: <20110501.204938.226758514.davem@davemloft.net>
References: <alpine.DEB.2.00.1104252128001.5889@pokey.mtv.corp.google.com>
	<20110429.115443.28811990.davem@davemloft.net>
	<BANLkTinFmfJbYxvZ+6rrAy+6XsfwF5an5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58906
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751966Ab1EBDuL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2011 23:50:11 -0400
In-Reply-To: <BANLkTinFmfJbYxvZ+6rrAy+6XsfwF5an5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Sun, 1 May 2011 19:41:34 -0700

> On Fri, Apr 29, 2011 at 11:54 AM, David Miller <davem@davemloft.net> =
wrote:
>> Add new interface, netdev_free_tx_skb(txq, skb) which can do the
>> completion accounting. =A0Actually the 'txq' argument is probably
>> superfluous as it can be obtained from the skb itself.
>>
> Okay, but I think the call at the end of TX completion processing is
> still probably needed.  The algorithm is trying to determine the
> number of bytes that completed at each interrupt.

Ok, then call it something generic like netdev_tx_complete() which
can serve other purposes in the future and not be bql specific.

>> Finally, you manage the bql limit logic in the existing generic netd=
ev
>> TX start/stop interfaces. =A0If the user asks for "start" but the bq=
l
>> is overlimit, simply ignore the request. =A0The driver will just sig=
nal
>> another "start" when the next TX packet completes.
>>
>> Similarly, when the qdisc is queuing up a packet to
>> dev_hard_start_xmit() you can, for example, preemptively do a "stop"
>> on the queue if you find bql is overlimit.
>>
> Unfortunately, there is still an additional complexity if we don't
> piggy back on the logic in the driver to stop the queue.  I believe
> that either this would require another queue state for queue being
> stopped for bql which looks pretty cumbersome, so that wrapping this
> in a qdisc might be a better possibility.

I'll leave it up to you what approach to try next.

Even thought I sort of side with you that bql is a largely seperate
facility from what we usually do with qdiscs, this TX completion
event could be very useful as an input to qdisc decision making.
