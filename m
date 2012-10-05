From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH] Packet mmap : allow the user to choose the offset of the
 tx payload.
Date: Fri, 5 Oct 2012 21:37:58 +0200
Message-ID: <CAD6jFURTMDL6WFGOJhMdnS3zuejYm0uaBPb1TYuNNdUS-7w89w@mail.gmail.com>
References: <1349442629-10960-1-git-send-email-paul.chavent@onera.fr>
	<CAD6jFUTmNiRHdAkckkwcV2rEOf_kxjHmntTO+rG6ewLs-RhFfg@mail.gmail.com>
	<7b317aa8fa2c96f3bf7ce916d18eb550@sybille.onecert.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, edumazet@google.com, xemul@parallels.com,
	herbert@gondor.hengli.com.au, netdev@vger.kernel.org,
	johann.baudy@gnu-log.net, uaca@alumni.uv.es
To: pchavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48405 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab2JETiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 15:38:07 -0400
Received: from [78.46.5.204] (helo=sslproxy02.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TKDin-0002RB-Lm
	for netdev@vger.kernel.org; Fri, 05 Oct 2012 21:38:05 +0200
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy02.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TKDWC-00060n-Tp
	for netdev@vger.kernel.org; Fri, 05 Oct 2012 21:25:04 +0200
Received: by mail-ee0-f46.google.com with SMTP id b15so1606222eek.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 12:37:58 -0700 (PDT)
In-Reply-To: <7b317aa8fa2c96f3bf7ce916d18eb550@sybille.onecert.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 5, 2012 at 9:21 PM, pchavent <Paul.Chavent@onera.fr> wrote:
> On Fri, 5 Oct 2012 16:17:12 +0200, Daniel Borkmann wrote:
>> On Fri, Oct 5, 2012 at 3:10 PM, Paul Chavent <Paul.Chavent@onera.fr>
>> wrote:
>>>
>>> The tx offset of packet mmap tx ring used to be :
>>> (TPACKET2_HDRLEN - sizeof(struct sockaddr_ll))
>>>
>>> The problem is that depending on the usage of SOCK_DGRAM or
>>> SOCK_RAW, the payload could be aligned or not.
>>>
>>> This patch allow to let the user give an offset for it's tx
>>> payload if he desires.
>>>
>>> Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
>>
>> Can you provide an example when it doesn't hit TPACKET_ALIGNMENT?
>
> When we use tx ring, the user have to write at (TPACKET_HDRLEN -
> sizeof(struct sockaddr_ll))
>
> This adress is aligned on TPACKET_ALIGNMENT since
> TPACKET_HDRLEN = (TPACKET_ALIGN(sizeof(struct tpacket_hdr)) + sizeof(struct
> sockaddr_ll))
>
> When we use the tx ring with SOCK_RAW option, the mac header is aligned on
> TPACKET_ALIGNMENT, but not the payload (14 bytes away).

Okay, I'm confused about your intentions, maybe I'm missing something.
The man-page of packet(7) clearly says:

The socket_type is either SOCK_RAW for raw packets *including* the
link level header or SOCK_DGRAM for cooked packets with  the link
level header *removed*.

So this is perfectly intended behavior of PF_PACKET.

Cheers,

Daniel
