From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Fri, 06 Jan 2012 11:43:38 -0800
Message-ID: <4F074EEA.4090905@hp.com>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com> <1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1325867504.2911.23.camel@edumazet-laptop> <CAA93jw7024Ejncj_Gjg9jcQF=HTERkc0dSCrVKrv7XJfELryow@mail.gmail.com> <1325869679.2911.27.camel@edumazet-laptop> <4F073DD5.6000006@hp.com> <1325878415.2911.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Kathleen Nichols <nichols@pollere.com>,
	Jim Gettys <jg@freedesktop.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:7029 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714Ab2AFTnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 14:43:40 -0500
In-Reply-To: <1325878415.2911.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2012 11:33 AM, Eric Dumazet wrote:
> Le vendredi 06 janvier 2012 =C3=A0 10:30 -0800, Rick Jones a =C3=A9cr=
it :
>
>> netperf nitpick :)  While I doubt that Dave Taht is running it that =
way,
>> one can have multiple requests in flight on a single _RR test via th=
e
>> test-specific -b<additionaltrans>  option.  That option is enabled b=
y
>> default (--enable-burst on the configure) in 2.5.0 and later.
>
> Ah Rick, I dont think we can tune IP_TOS with netperf -t UDP_{STREAM|
> RR} ?
>
> I ask because it could be a good thing to set ECT(0) on datagrams to
> check our ECN capabilities and get in the final report from receiver =
a
> count/percentage of CE frames.

=46unny you should mention that :)  In the top-of-trunk (perhaps it is =
in=20
2.5.0 too, I do not recall) there is the global -Y option:

$ src/netperf -Y
src/netperf: option requires an argument -- 'Y'

Usage: netperf [global options] -- [test options]

Global options:
=2E..
     -y local,remote   Set the socket priority
     -Y local,remote   Set the IP_TOS. Use hexadecimal.

So long as you either use the omni code directly, or indirectly by not=20
undoing WANT_MIGRATION those should work - for some definition of work=20
anyway...I would not be surprised to learn there are bugs in the suppor=
t.

However, there is nothing presently in the netperf code to cause any=20
*individual* send to be so marked independently of the others.

happy benchmarking,

rick jones
