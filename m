From: Prashanth <bshanth@gmail.com>
Subject: Re: ip_finish_outpu2 question
Date: Wed, 14 May 2008 10:53:36 +0530
Message-ID: <7aa53e090805132223q5f1bef51re636cde33f5dfde4@mail.gmail.com>
References: <7aa53e090805132042k5476eaf6lb66e534232154bf5@mail.gmail.com>
	 <20080513.213425.03637016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.242]:17270 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbYENFXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 01:23:37 -0400
Received: by hs-out-0708.google.com with SMTP id 4so2463384hsl.5
        for <netdev@vger.kernel.org>; Tue, 13 May 2008 22:23:36 -0700 (PDT)
In-Reply-To: <20080513.213425.03637016.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So skb->data will be pointing to an unaligned memory address; atleast
for the ethernet case which has 14 Bytes header length.
because of this my chip is not allowing to do DMA for unaligned memory address.

If we take the case of ethernet , The hh->hh_data will be pointing to
the ethernet header by leaving the first 2 bytes.
HH_DATA_OFF() macro is used for this purpose.

By doing skb_push() only for 14 bytes and making skb->data to point to
unaligned memory will have performance hit,
In my case i was not even  able to xmit the packet.So is it not better
to do skb_push() for 16 bytes and make skb->data aligned?

In ip_finish_output2() function  it's better to do skb_push() for
aligned length. And let others access the ethernet header
by adding HH_DATA_OFF() to it. Do we face any problems by doing this.

Please fix me if i'm wrong.

Thanks

On Wed, May 14, 2008 at 10:04 AM, David Miller <davem@davemloft.net> wrote:
> From: Prashanth <bshanth@gmail.com>
> Date: Wed, 14 May 2008 09:12:54 +0530
>
>> hi, In the following function at line 189 , we are getting aligned
>> length (hh_alen) for the hardware header , but while doing a
>> skb_push() why are we using the hh->hh_len;for ethernet hh_alen would
>> be 16 , and hh->hh_len would be 14, since we are doing skb_push() with
>> 14 (i.e hh->hh_len), the skb->data will not be aligned right? Can
>> someone please shed some light on this. thanks.
>
> We are using 16 for the copy so that we do an aligned
> copy.  But the ethernet header size is only 14 bytes.
>
> It's safe to copy those extra 2 bytes at the front
> since we always will have some extra slack space there.
>
