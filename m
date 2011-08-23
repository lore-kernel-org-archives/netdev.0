From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: TCP - RST flag
Date: Wed, 24 Aug 2011 01:05:07 +0300
Message-ID: <CAEnQRZB2-2FiLPiv6mhsJFgtQS3X5N0xQJfnV9S=kTMkz0f77g@mail.gmail.com>
References: <CAEnQRZAchYf-3-t7RRogfb0WogzY9ZF8rzMdtOeS1Vdvx7N4og@mail.gmail.com>
	<1314132932.4478.0.camel@edumazet-laptop>
	<CAEnQRZChkX0K_qWf-Gmu8YeAyxoOb7DTPvvbnA5YxSHEMj_J=g@mail.gmail.com>
	<1314136220.4478.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	kernelnewbies <kernelnewbies@kernelnewbies.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:48355 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515Ab1HWWFJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 18:05:09 -0400
Received: by qwk3 with SMTP id 3so392200qwk.19
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 15:05:08 -0700 (PDT)
In-Reply-To: <1314136220.4478.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2011 at 12:50 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mercredi 24 ao=FBt 2011 =E0 00:32 +0300, Daniel Baluta a =E9crit :
>> On Tue, Aug 23, 2011 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>
>> > TCP in RFC 1122 section 4.2.2.13:
>> >
>> > =A0"A host MAY implement a "half-duplex" TCP close sequence, so th=
at an
>> > =A0application that has called CLOSE cannot continue to read data =
from the
>> > =A0connection. If such a host issues a CLOSE call while received d=
ata is
>> > =A0still pending in TCP, or if new data is received after CLOSE is=
 called,
>> > =A0its TCP SHOULD send a RST to show that data was lost."
>>
>> So, this means that server's CLOSE operation is issued while receive=
d
>> data is still pending? I will analyze ftp's server code, but this is=
 strange
>> since P4 [221 Have a nice day!\r\n] it is generated as a response fo=
r
>> P3 [QUIT\r\n]. So P4 must have been fully received.
>>
>
> tcpdump only shows TCP stack did receive the frame, not that it was
> _read_ by application.
>
> Only strace could eventually say if the input queue was really draine=
d
> before the close().
> Maybe server decided to close the connexion before reading the QUIT
> command from client.
>
>> Also, looking at the capture no data is received from the client aft=
er
>> server calls CLOSE (P5) (there are only ACKs and FIN - P6, P7, P8).
>
> That doesnt matter.
>
> If data was received (and ACKnowledged by TCP stack) _before_ close(f=
d),
> but not yet read by application, TCP must send an RST to be RFC
> compliant.

I see. Thanks a lot for your explanations. I will further use strace
to see what's going on.

Daniel.
