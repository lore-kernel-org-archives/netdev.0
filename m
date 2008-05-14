From: David Miller <davem@davemloft.net>
Subject: Re: ip_finish_outpu2 question
Date: Tue, 13 May 2008 21:34:25 -0700 (PDT)
Message-ID: <20080513.213425.03637016.davem@davemloft.net>
References: <7aa53e090805132042k5476eaf6lb66e534232154bf5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bshanth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55425
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751253AbYENEeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 00:34:31 -0400
In-Reply-To: <7aa53e090805132042k5476eaf6lb66e534232154bf5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashanth <bshanth@gmail.com>
Date: Wed, 14 May 2008 09:12:54 +0530

> hi, In the following function at line 189 , we are getting aligned
> length (hh_alen) for the hardware header , but while doing a
> skb_push() why are we using the hh->hh_len;for ethernet hh_alen would
> be 16 , and hh->hh_len would be 14, since we are doing skb_push() with
> 14 (i.e hh->hh_len), the skb->data will not be aligned right? Can
> someone please shed some light on this. thanks.

We are using 16 for the copy so that we do an aligned
copy.  But the ethernet header size is only 14 bytes.

It's safe to copy those extra 2 bytes at the front
since we always will have some extra slack space there.
