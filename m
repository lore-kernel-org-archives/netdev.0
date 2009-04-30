From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Thu, 30 Apr 2009 22:17:30 +0200
Message-ID: <7e0dd21a0904301317y9b62f91x5e71ee5c52fbfbd4@mail.gmail.com>
References: <1240751189.5771.19.camel@bender>
	 <20090429091803.GA23463@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Christoph Lameter <cl@linux.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:63749 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbZD3URc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 16:17:32 -0400
Received: by fxm2 with SMTP id 2so2036628fxm.37
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2009 13:17:30 -0700 (PDT)
In-Reply-To: <20090429091803.GA23463@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Evgeniy for your review.

> I suppose kernel sends packets with the status field equal to
> TP_STATUS_SEND_REQUEST not TP_STATUS_AVAILABLE.
Yes, this is a mistake.

> Besides several codying style issues, like placing { on the new line
> from the same one, missing space near the operator like if(smth),
> switch(smth), things look good.
Ok, I will update this patch according to coding rules and resubmit.

Thanks,
Johann


On Wed, Apr 29, 2009 at 11:18 AM, Evgeniy Polyakov <zbr@ioremap.net> wr=
ote:
> On Sun, Apr 26, 2009 at 03:06:29PM +0200, Johann Baudy (johann.baudy@=
gnu-log.net) wrote:
>> +++ Transmission process
>> +Those defines are also used for transmission:
>> +
>> + =A0 =A0 #define TP_STATUS_AVAILABLE =A0 =A0 =A0 =A00 // Frame is a=
vailable
>> + =A0 =A0 #define TP_STATUS_SEND_REQUEST =A0 =A0 1 // Frame will be =
sent on next send()
>> + =A0 =A0 #define TP_STATUS_SENDING =A0 =A0 =A0 =A0 =A02 // Frame is=
 currently in transmission
>> + =A0 =A0 #define TP_STATUS_WRONG_FORMAT =A0 =A0 4 // Frame format i=
s not correct
>> +
>> +First, the kernel initializes all frames to TP_STATUS_AVAILABLE. To=
 send a
>> +packet, the user fills a data buffer of an available frame, sets tp=
_len to
>> +current data buffer size and sets its status field to TP_STATUS_SEN=
D_REQUEST.
>> +This can be done on multiple frames. Once the user is ready to tran=
smit, it
>> +calls send(). Then all buffers with status equal to TP_STATUS_AVAIL=
ABLE are
>
> I suppose kernel sends packets with the status field equal to
> TP_STATUS_SEND_REQUEST not TP_STATUS_AVAILABLE.
>
> Besides several codying style issues, like placing { on the new line
> from the same one, missing space near the operator like if(smth),
> switch(smth), things look good.
>
> --
> =A0 =A0 =A0 =A0Evgeniy Polyakov
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Johann Baudy
johaahn@gmail.com
