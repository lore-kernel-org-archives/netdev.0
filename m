From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 17:00:39 -0800
Message-ID: <CANP3RGcPhry4S3-+SuTtVGCd=Ln4jQ0LrDb_V5bAFUpdzFojBA@mail.gmail.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	<20151119.005318.838757439536205791.davem@davemloft.net>
	<CAKD1Yr0Es9JqdDi_05Kif=TyCSA+n7yDHUNr-ND-SD4j4p=D9A@mail.gmail.com>
	<20151119.195504.2050784646947745419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux NetDev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36288 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161118AbbKTBAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 20:00:40 -0500
Received: by iofh3 with SMTP id h3so108622542iof.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 17:00:39 -0800 (PST)
In-Reply-To: <20151119.195504.2050784646947745419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> In this case, userspace knows that that app's connections are now
>> unusable because it configured an iptables rule to block them. The
>> kernel doesn't really know until it the time comes to send a packet,
>> and maybe not even then.
>
> Netfilter could perform signalling on skb->sk when it drops packets.
>
> Your example is actually a argument _for_ doing this in the kernel.

That only (currently) works if a socket actually tries to send something.

Idle sockets (for example a socket used for push notification from the
remote server) still end up blocking forever.

If you were to, whenever the firewall configuration is changed,
iterate through all sockets in the system and generate a pair of fake
0-data packets (for both directions) for every socket to see if it
would get blocked by the firewall... but that seems quite insane.
