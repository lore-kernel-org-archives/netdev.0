From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT sample
Date: Tue, 10 Apr 2012 13:46:38 -0700
Message-ID: <CAA93jw5opbBobzkgJ2diRPu2X0aKOsnF9hmcm_LfsLPipeAK7g@mail.gmail.com>
References: <1334080760-968-1-git-send-email-ncardwell@google.com>
	<20120410.144737.1047745906309843732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, netdev@vger.kernel.org, nanditad@google.com,
	ycheng@google.com, edumazet@google.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35088 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755324Ab2DJUqj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 16:46:39 -0400
Received: by wibhq7 with SMTP id hq7so195798wib.1
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 13:46:38 -0700 (PDT)
In-Reply-To: <20120410.144737.1047745906309843732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 11:47 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Neal Cardwell <ncardwell@google.com>
> Date: Tue, 10 Apr 2012 13:59:20 -0400
>
>> Fix a code path in tcp_rcv_rtt_update() that was comparing scaled an=
d
>> unscaled RTT samples.
>>
>> The intent in the code was to only use the 'm' measurement if it was=
 a
>> new minimum. =A0However, since 'm' had not yet been shifted left 3 b=
its
>> but 'new_sample' had, this comparison would nearly always succeed,
>> leading us to erroneously set our receive-side RTT estimate to the '=
m'
>> sample when that sample could be nearly 8x too high to use.
>>
>> The overall effect is to often cause the receive-side RTT estimate t=
o
>> be significantly too large (up to 40% too large for brief periods in
>> my tests).
>>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>
> Applied, thanks.
> --


awesome, is this needed in stable?

--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
