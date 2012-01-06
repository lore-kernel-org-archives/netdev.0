From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Fri, 6 Jan 2012 18:36:07 +0100
Message-ID: <CAA93jw6QS3OVUoruX+QEUQL9GiC5=3_q9KKpn8zmuXj0H6vKBA@mail.gmail.com>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	<1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325867504.2911.23.camel@edumazet-laptop>
	<CAA93jw7024Ejncj_Gjg9jcQF=HTERkc0dSCrVKrv7XJfELryow@mail.gmail.com>
	<1325869679.2911.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Kathleen Nichols <nichols@pollere.com>,
	Jim Gettys <jg@freedesktop.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:62139 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758813Ab2AFRgK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 12:36:10 -0500
Received: by obcwo16 with SMTP id wo16so2127233obc.19
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 09:36:10 -0800 (PST)
In-Reply-To: <1325869679.2911.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2012 at 6:07 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le vendredi 06 janvier 2012 =E0 17:56 +0100, Dave Taht a =E9crit :
>> On Fri, Jan 6, 2012 at 5:31 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> > Adds an optional Random Early Detection on each SFQ flow queue.
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
>
> So there is no differences for them.


Your environment is rather different than mine, and I like having
baseline numbers around... but I can live without as I was hovering
over the build button in my bql tree, and I'm building now.

Up until the world changed, a few days ago, those two did matter when
comparing results against QFQ and
various combinations of it's sub-qdiscs. I'm at the point now where I
have to do cdf plots against large data sets in order to see
*anything*, and I'm looking forward to seeing how well this does
against wireless, which is really noisy...

TCP_MAERTS tests activity in the other direction and (again, your
environment is different) does interesting things against byte
oriented red, or rather, 'did' when last I checked several eons
(months) ago, which was prior to the avqueue fixes.

Another excellent test is the 'apache benchmark', ab, while under a
saturating load from something else.

At some point I'd like to try iobench against nfs and samba, even
iscsi against multiple initiators...

--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
