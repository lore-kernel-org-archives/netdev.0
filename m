From: Nicholas Van Orton <turanammo@gmail.com>
Subject: Re: e100 skb allocation
Date: Wed, 24 Jun 2009 21:58:38 +0530
Message-ID: <b9e8fcbd0906240928h6c5db9a6va48e42799376149e@mail.gmail.com>
References: <b9e8fcbd0906240149g2f2e18f2vcd7dce234c949564@mail.gmail.com>
	 <20090624104750.GA18486@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:3194 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149AbZFXQ2h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 12:28:37 -0400
Received: by rv-out-0506.google.com with SMTP id f6so241432rvb.1
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 09:28:38 -0700 (PDT)
In-Reply-To: <20090624104750.GA18486@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 4:17 PM, Neil Horman<nhorman@tuxdriver.com> wro=
te:
> On Wed, Jun 24, 2009 at 02:19:48PM +0530, Nicholas Van Orton wrote:
>> Hello,
>>
>> =A0 =A0 =A0 For the Intel 8256 Ethernet Controller (e100.c), I notic=
e that at the
>> time of skb allocation using netdev_alloc_skb() and just before
>> calling skb_reserve(), rx->skb->head and rx->skb->tail do not point =
to
>> the same location. In fact they are already 16bytes apart. After
>> calling =A0skb_reserve(), which would add a 2 byte padding, head and
>> tail would be 18 bytes apart. Is this behaviour correct? Shouldn't t=
he
>> ethernet header be 14+2 bytes after padding? Why aren't head and tai=
l
>> at the same location at the beginning?
>>
> Yes, its fine (although IIRC it should be 32, rather than 16 bytes).
> netdev_alloc_skb, in its implementation, allocates an skb that is NET=
_SKB_PAD
> bytes larger than the caller requested, then it calls skb_reserve int=
ernally to
> add NET_SKB_PAD bytes of data to the skb's buffer.
>

Thanks a bunch for steering me in the right direction. Things are much
clearer now.

Regards,
Nicholas
