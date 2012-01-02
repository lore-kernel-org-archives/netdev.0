From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 2 Jan 2012 17:08:26 +0100
Message-ID: <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:47082 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584Ab2ABQIs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 11:08:48 -0500
Received: by wibhm6 with SMTP id hm6so8482573wib.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 08:08:47 -0800 (PST)
In-Reply-To: <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/2 Eric Dumazet <eric.dumazet@gmail.com>:
> Le lundi 02 janvier 2012 =C3=A0 16:21 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>> Hi all,
>>
>> I am currently working on a way to send raw images (~400*300 YUV
>> 4:2:0) at a relative high speed (raw image and not compressed image
>> due to specific codec issues).
>> This would represent about 57MBps/sec on a 100Mbps ethernet link.
>> This link is direct, nothing else will pass through it.
>>
>> My question is a performance and efficiency question. Here is what I
>> am thinking about :
>> - I have the image on one computer at a known memory adress
>> - I want top transmit this picture using TCP packets with the rule
>> "1row =3D 1packet", maybe "2rows=3D1packet"
>> - All these packets have to go on an ethernet link and will be
>> received on another computer starting at a known memory adress
>> Something like this :
>> http://imageshack.us/photo/my-images/15/tcpmemory.png/
>>
>> I was thinking about using TCP socket (of course) and the sendfile
>> syscall on sender side, splice syscall on the receiver side, but I
>> don't know if this is the best (and fastest) way to do it ?
>> I would like to avoid memory copy as much as possible as the systems
>> on which it will be done are embedded arm computers.
>> TCP is chosen in order to get ordered packets, but maybe am I wrong =
?
>>
>> Thanks for any clues you can give !
>> Regards,
>> JM
>> --
>
> Do you really need full image, or are some missing lines allowed ?
>
> What is the length in bytes for a line ?

I can't accept any missing line, and line length in bytes is to be
decided but I think it would be something like 672bytes. This is why I
would put two lines per packet.

> TCP stream and your bandwidth requirements would work only if you
> guarantee not a single packet loss.
>
> Using UDP (RTP) would allow you to respect any time limits at the
> sender, yet allowing some drops on the network.

Yes, and again, I don't want any missing lines :).

> If you use a direct link, packets wont be re-ordered.
>
> Is your ARM platform so slow it cannot afford copying 10 Mbytes per
> second in skb ?

I don't really know what it can do, but it has to do encoding (even if
it is a SoC, with dedicated devices, memory has to be used).
The main problem I have, is that I don't have the two boards with me
today, and even if I can prototype on x86, I can't conclude as far as
I don't test on the real HW.
This is also why I want to prototype my best bet in the first try :).
And this is mainly a networking/memory problem.

Thanks for answering.
JM
