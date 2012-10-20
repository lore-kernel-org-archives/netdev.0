From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH net-next] packet mmap : allow the user to choose tx data offset.
Date: Sat, 20 Oct 2012 19:35:27 +0200
Message-ID: <CAD6jFUSgQKmss=nBaK=8ZpX1Gz-XdNf6p6kazO1_nMcm0pkmCA@mail.gmail.com>
References: <1350631302-16280-1-git-send-email-paul.chavent@onera.fr>
	<CAD6jFURov5oB+ck33JzCYQoBo9mYsEM9c0rHz9gmcgdMKgmwCg@mail.gmail.com>
	<50815908.1050308@onera.fr>
	<CAD6jFURS6FXvZJttxEn-qPP5=sWCOHSx=BeSgiJM+ZemAkuKdQ@mail.gmail.com>
	<535a652cffb4d52cbae20e06a95d724d@sybille.onecert.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: pchavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32890 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756316Ab2JTRff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 13:35:35 -0400
Received: from [78.46.5.204] (helo=sslproxy02.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TPcxS-00085a-3w
	for netdev@vger.kernel.org; Sat, 20 Oct 2012 19:35:34 +0200
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy02.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TPcxO-0006wc-UI
	for netdev@vger.kernel.org; Sat, 20 Oct 2012 19:35:30 +0200
Received: by mail-ee0-f46.google.com with SMTP id b15so530745eek.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 10:35:27 -0700 (PDT)
In-Reply-To: <535a652cffb4d52cbae20e06a95d724d@sybille.onecert.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 20, 2012 at 7:13 PM, pchavent <Paul.Chavent@onera.fr> wrote:
> Hi Daniel
>
>
>>>>> +                       switch (po->tp_version) {
>>>>> +                       case TPACKET_V2:
>>>>> +                               off = ph.h2->tp_mac;
>>>>> +                               break;
>>>>> +                       default:
>>>>> +                               off = ph.h1->tp_mac;
>>>>
>>>>
>>>>
>>>> TPACKET_V1 as default is wrong since there's also TPACKET_V3. What
>>>> about TPACKET_V3 in general in your patch? You simply ignore it.
>>>
>>>
>>>
>>> I have reproduced the pattern found some lines above (1868-1875)
>>>
>>> switch (po->tp_version) {
>>> case TPACKET_V2:
>>>         tp_len = ph.h2->tp_len;
>>>         break;
>>> default:
>>>         tp_len = ph.h1->tp_len;
>>>         break;
>>> }
>>>
>>> Do you suggest me to add a case TPACKET_V3 and get tp_len from
>>> ph.h3->tp_len
>>> ?
>>
>>
>> If I'm not mistaken, with your current patch you can do the
>> setsockopt(2) call on a tpacket v3 socket and then default to a
>> tpacket v1 in your switch statement. This doesn't seem right. Thus,
>> this should better be fixed in whatever way.
>
>
> It seems that "Opening a Tx-ring is NOT supported in TPACKET_V3" (see
> comment in packet_set_ring). So no one could be able to use the TX_OFF
> feature with a TPACKET_V3.
>
> The tpacket_snd function call some subroutines that call WARN and BUG (like
> in __packet_set_status),
> and other ones that simply ignore the tpacket v3 case (like in
> tpacket_fill_skb).
>
> What do you suggest ?
>
> I add a case that call WARN and BUG like in {__packet_set_status,
> __packet_get_status, packet_increment_rx_head} where we get tp_len in the
> tpacket_fill_skb function ?
>
> Or i let the code as is ?

Hmm, ok. Then maybe for the moment having it similar like the rest
seems fine. So, if one day someone adds a TX_RING to TPACKET_V3, this
needs to be addressed as well. Probably letting the code as is might
be okay for now.
