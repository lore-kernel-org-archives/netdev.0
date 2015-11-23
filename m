From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 23 Nov 2015 09:33:44 -0800
Message-ID: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
	<1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davewatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36674 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbbKWRdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 12:33:45 -0500
Received: by igcph11 with SMTP id ph11so55853687igc.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 09:33:44 -0800 (PST)
In-Reply-To: <1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> For me this still looks a little bit like messages could be delimited by
> TCP PSH flag, where we might need to have some more fine grained control
> over and besides that just adding better fanout semantics to TCP, no?
>
The TCP PSH flag is not defined for message delineation (neither is
urgent pointer). We can't change that (many people have tried to add
message semantics to TCP protocol but have always failed miserably).
The fact is TCP is always going to be a stream based protocol. Period!
:-) It is up to the application to interpret the stream and extract
messages. Even if we could somehow apply the PSH bit to "help" in
message delineation, we would need to change senders to use the PSH
bit in that fashion for it to be of benefit to receivers.

> Do kcm sockets still allow streaming unlimited amounts of data? E.g. if
> you want to pass a data stream attached to a rpc message? I think not
> allowing streaming is a major shortcoming then (even though this will
> induce head of line blocking).
>
RPC messages can be of arbitrary size and with SOCK_SEQPACKET,
messages can be sent or received in multiple calls. No HOL blocking
since message are constructed on KCM sockets before starting to send
on TCP sockets. Socket buffer limits are respected. KCM does not
enforce a maximum message size, if an applications does have a maximum
then that can be checked in the BPF code.

>> Future support:
>>
>>  - Integration with TLS (TLS-in-kernel is a separate initiative).
>
> This is interesting:
>
> Regarding the last week's discussion about better OOB support in TCP
> e.g. for SOCKET_DESTROY, do you already have a plan to handle TLS alerts
> and do CHANGE_CIPHER on the socket synchronously?
>
Dave should be posting the basic TLS-in-the-kenel patches shortly,
those will be a better context for discussion.

Tom
