From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] net_sched: red: split red_parms into parms and vars
Date: Thu, 5 Jan 2012 14:03:43 +0100
Message-ID: <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60461 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754999Ab2AENDo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 08:03:44 -0500
Received: by ggdk6 with SMTP id k6so160985ggd.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 05:03:43 -0800 (PST)
In-Reply-To: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 5, 2012 at 1:25 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> This patch splits the red_parms structure into two components.
>
> One holding the RED 'constant' parameters, and one containing the
> variables.
>
> This permits a size reduction of GRED qdisc, and is a preliminary ste=
p
> to add an optional RED unit to SFQ.

ah. I see where you are going with this. You are trying also to get you=
r
'time in red' adaptation idea done, aren't you, or at least lay the gro=
undwork
for that?

Are you trying to make the 3.3 merge window for all this?

I don't want to discourage you in any way, but byte oriented RED
with or without TSO doesn't work in your typical asymmetric
environment. If you set an appropriate byte limit for
stuff going one way, you end up with acks going out of
control - and vice versa.

and/or packet oriented RED has some hope, but in either
case you have to do something intelligent with a giant TSO
stream if you are going to use it on a server or host.

And the basic red still has two flaws that may or may
not go away with your adaptation, or combination with
SFQ - (I do retain hope, though)

I think you already grok this and you've already got the solution
outlined :)

so I'm going to go away now and finish writing up
what the problems are in sch_md, which are legion...

Keep having fun. I'll plan on a new build by the weekend.

--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
