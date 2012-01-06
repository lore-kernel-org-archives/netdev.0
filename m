From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Fri, 06 Jan 2012 10:30:45 -0800
Message-ID: <4F073DD5.6000006@hp.com>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com> <1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1325867504.2911.23.camel@edumazet-laptop> <CAA93jw7024Ejncj_Gjg9jcQF=HTERkc0dSCrVKrv7XJfELryow@mail.gmail.com> <1325869679.2911.27.camel@edumazet-laptop>
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
Received: from g1t0027.austin.hp.com ([15.216.28.34]:7726 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758899Ab2AFSas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 13:30:48 -0500
In-Reply-To: <1325869679.2911.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2012 09:07 AM, Eric Dumazet wrote:
> Le vendredi 06 janvier 2012 =C3=A0 17:56 +0100, Dave Taht a =C3=A9cri=
t :
>> On Fri, Jan 6, 2012 at 5:31 PM, Eric Dumazet<eric.dumazet@gmail.com>=
  wrote:
>>> Adds an optional Random Early Detection on each SFQ flow queue.
>>
>> netperf -t TCP_RR is useful
>> -t TCP_MAERTS will be interesting.
>> simultaneous ping?
>>
>
> I dont know what you expect from pings, since they are already coming=
 in
> new flows (unless a ping flood is in effect), so RED doesnt fire for
> these packets.
>
> Same for TCP_RR : Since at most one packet is in flight per flow, RED
> cannot fire.

netperf nitpick :)  While I doubt that Dave Taht is running it that way=
,=20
one can have multiple requests in flight on a single _RR test via the=20
test-specific -b <additionaltrans> option.  That option is enabled by=20
default (--enable-burst on the configure) in 2.5.0 and later.

netperf -t TCP_RR ...  -- -b 1

will cause netperf to have two transactions in flight at one time, -b 3=
=20
will have four etc etc (actually it "slow-starts" to get to that level)=
=2E=20
  This can also be (ab)used to implement a single-connection,=20
bi-directional throughput test such as I have in my "runemomni" scripts=
=20
under doc/examples.  For example:

netperf -t TCP_RR ... -- -s 1M -S 1M -r 64K -b 12

As there is no select() or poll() call in the path, it is best to ensur=
e=20
that the SO_SNDBUF size on either end is large enough to hold=20
[request|response]_size*simultaneous_trans at one time.

Depending on the size of the requests/responses one may want to add the=
=20
test-specific -D option to set TCP_NODELAY.

happy benchmarking,

rick jones
