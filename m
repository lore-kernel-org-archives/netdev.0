From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] Documentation/networking: more accurate LCO explanation
Date: Fri, 6 May 2016 09:29:56 -0700
Message-ID: <CAKgT0UcpbKVpip0pSaCOY7xVQ=3wwUxFing7Sht8ptH8VRB=FA@mail.gmail.com>
References: <1462550263-9742-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Edward Cree <ecree@solarflare.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34085 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272AbcEFQ35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 12:29:57 -0400
Received: by mail-io0-f176.google.com with SMTP id 190so119368960iow.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 09:29:57 -0700 (PDT)
In-Reply-To: <1462550263-9742-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 6, 2016 at 8:57 AM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> In few places the term "ones-complement sum" was used but the actual
> meaning is "the complement of the ones-complement sum".

Looks like there might still be a few minor corrections needed.
Comments inline below.

>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> ---
>
>  I assume readers interpret the term "ones-complement sum" as the sum
>  using one's complement arithmentic, without the final bitwise
>  complement of sum's result.
>  Hence I added "the complement of" where applicable.
>
>  Documentation/networking/checksum-offloads.txt | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/Documentation/networking/checksum-offloads.txt b/Documentation/networking/checksum-offloads.txt
> index de2a327766..9567200e1f 100644
> --- a/Documentation/networking/checksum-offloads.txt
> +++ b/Documentation/networking/checksum-offloads.txt
> @@ -69,17 +69,17 @@ LCO: Local Checksum Offload
>  LCO is a technique for efficiently computing the outer checksum of an
>   encapsulated datagram when the inner checksum is due to be offloaded.
>  The ones-complement sum of a correctly checksummed TCP or UDP packet is
> - equal to the sum of the pseudo header, because everything else gets
> - 'cancelled out' by the checksum field.  This is because the sum was
> + equal to the complement of the sum of the pseudo header, because everything
> + else gets 'cancelled out' by the checksum field.  This is because the sum was
>   complemented before being written to the checksum field.
>  More generally, this holds in any case where the 'IP-style' ones complement
>   checksum is used, and thus any checksum that TX Checksum Offload supports.
>  That is, if we have set up TX Checksum Offload with a start/offset pair, we
>   know that _after the device has filled in that checksum_, the ones
>   complement sum from csum_start to the end of the packet will be equal to
> - _whatever value we put in the checksum field beforehand_.  This allows us
> - to compute the outer checksum without looking at the payload: we simply
> - stop summing when we get to csum_start, then add the 16-bit word at
> + the complement of _whatever value we put in the checksum field beforehand_.

I don't really see the point of using an underscore before and after
that statement.  If it was only one or two words it might work for
emphasis but the statement is large enough that starting it with an
underscore just makes it harder to read.

> + This allows us to compute the outer checksum without looking at the payload:
> + we simply stop summing when we get to csum_start, then add the 16-bit word at
>   (csum_start + csum_offset).

You don't add the 16-bit word you add the compliment of the 16 bit word.
