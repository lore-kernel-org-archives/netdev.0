From: Tom Herbert <tom@herbertland.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 09:38:37 -0800
Message-ID: <CALx6S379hXL=QEBF-HmOvPr3K55tS87HV=wKOySro1A0ogmWcQ@mail.gmail.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	<20151119.005318.838757439536205791.davem@davemloft.net>
	<CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	<20151119.104811.1447518072450380661.davem@davemloft.net>
	<1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	<1447952902.2049284.444501617.7C422D07@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, zenczykowski@gmail.com,
	Lorenzo Colitti <lorenzo@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34106 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758946AbbKSRih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 12:38:37 -0500
Received: by ioir85 with SMTP id r85so96900126ioi.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 09:38:37 -0800 (PST)
In-Reply-To: <1447952902.2049284.444501617.7C422D07@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I actually don't have an issue with killing from user space that much. I
> still recommend (and actually have started to look at it today) to add a
> new substate for TCP TIMEWAIT and don't have any issue if we block the
> socket for 60 seconds and send RSTs to all incoming data. This way we
> can solve the problem Florian indicated as well as this problem. Users
> can happily kill TCP connections then.
>
Neither do I have a problem with killing connections from userspace,
but we do have to acknowledge that this is a powerful and invasive
mechanism. I suggest:

1) We need transparency. If a third party kills a TCP connection then
the application should be informed of specifically that. This seems
easy enough to just pick an appropriate error number as I suggested.
2) We need constraints. This feature seems to be specific to a very
narrow use case. It is not at all clear to me if there are any
legitimate uses cases beyond Android, enabling this by default in the
stack creates a non-zero amount of risk and liability for abuse. It
seems like this should be an opt-in sort of feature, with a kernel
CONFIG or maybe opt-in per socket.

Tom

> Bye,
> Hannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
