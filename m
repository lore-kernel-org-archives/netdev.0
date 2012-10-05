From: pchavent <Paul.Chavent@onera.fr>
Subject: Re: [PATCH] Packet mmap : allow the user to choose the offset of
 the tx payload.
Date: Fri, 05 Oct 2012 21:21:22 +0200
Message-ID: <7b317aa8fa2c96f3bf7ce916d18eb550@sybille.onecert.fr>
References: <1349442629-10960-1-git-send-email-paul.chavent@onera.fr>
 <CAD6jFUTmNiRHdAkckkwcV2rEOf_kxjHmntTO+rG6ewLs-RhFfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <edumazet@google.com>,
	<xemul@parallels.com>, <herbert@gondor.hengli.com.au>,
	<netdev@vger.kernel.org>, <johann.baudy@gnu-log.net>,
	<uaca@alumni.uv.es>
To: Daniel Borkmann <danborkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:56050 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636Ab2JETX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 15:23:29 -0400
In-Reply-To: <CAD6jFUTmNiRHdAkckkwcV2rEOf_kxjHmntTO+rG6ewLs-RhFfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Fri, 5 Oct 2012 16:17:12 +0200, Daniel Borkmann wrote:
> On Fri, Oct 5, 2012 at 3:10 PM, Paul Chavent <Paul.Chavent@onera.fr> 
> wrote:
>> The tx offset of packet mmap tx ring used to be :
>> (TPACKET2_HDRLEN - sizeof(struct sockaddr_ll))
>>
>> The problem is that depending on the usage of SOCK_DGRAM or
>> SOCK_RAW, the payload could be aligned or not.
>>
>> This patch allow to let the user give an offset for it's tx
>> payload if he desires.
>>
>> Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
>
> Can you provide an example when it doesn't hit TPACKET_ALIGNMENT?

When we use tx ring, the user have to write at (TPACKET_HDRLEN - 
sizeof(struct sockaddr_ll))

This adress is aligned on TPACKET_ALIGNMENT since
TPACKET_HDRLEN = (TPACKET_ALIGN(sizeof(struct tpacket_hdr)) + 
sizeof(struct sockaddr_ll))

When we use the tx ring with SOCK_RAW option, the mac header is aligned 
on TPACKET_ALIGNMENT, but not the payload (14 bytes away).


>
> On the first look, could it be that your patch currently enforces the
> use of your tp_net's offset for *all* TX_RING users, even if they
> don't care about it? So in case off==0, you probably get a negative
> offset in case of SOCK_RAW, thus it won't hit the second 
> if-statement.
> Sure, but this does not look intuitive in my opinion. Maybe, it's
> better to only enter this path if the offset *is* used by someone.

Yes, moreover i had a problem with the signed/unsigned comparison.
I've fixed all those problems for the next submission.


>
> Also, to my knowledge tp_net is currently only applied in receive
> path. So, if for whatever reason people did not explicitly set tp_net
> to 0, it might break their code, if there's a random offset in it,
> right?

I haven't found where all frames were initialized to 
TP_STATUS_AVAILABLE, so i have supposed that the frames were initialized 
to zero.

So your are right, if tp_net is not forced to zero before sending the 
packet it could break the legacy code :(


>
> Best,
> Daniel

Thank for your review.

Paul.
