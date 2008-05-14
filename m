From: David Miller <davem@davemloft.net>
Subject: Re: ip_finish_outpu2 question
Date: Tue, 13 May 2008 22:46:33 -0700 (PDT)
Message-ID: <20080513.224633.229128314.davem@davemloft.net>
References: <7aa53e090805132042k5476eaf6lb66e534232154bf5@mail.gmail.com>
	<20080513.213425.03637016.davem@davemloft.net>
	<7aa53e090805132223q5f1bef51re636cde33f5dfde4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bshanth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35623
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752402AbYENFqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 01:46:39 -0400
In-Reply-To: <7aa53e090805132223q5f1bef51re636cde33f5dfde4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashanth <bshanth@gmail.com>
Date: Wed, 14 May 2008 10:53:36 +0530

> So skb->data will be pointing to an unaligned memory address;
> atleast for the ethernet case which has 14 Bytes header length.

That's correct.

> because of this my chip is not allowing to do DMA for unaligned
> memory address.

Most chips have an "packet offset" parameter you can feed into the TX
descriptor, and you align the DMA address that is given to the
chip.  This allows the chip to do an aligned DMA fetch yet still
be agnostic the the alignment of the packet given to it by the
networking stack.

> So is it not better
> to do skb_push() for 16 bytes and make skb->data aligned?

If we did that skb->data would point to the two garbage bytes
in front of the ethernet header.

> In ip_finish_output2() function it's better to do skb_push() for
> aligned length. And let others access the ethernet header by adding
> HH_DATA_OFF() to it. Do we face any problems by doing this.

No, that would punish good hardware which can handle arbitrary
TX packet alignment for the sake of bad hardware.
