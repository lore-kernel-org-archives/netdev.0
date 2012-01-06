From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Fri, 6 Jan 2012 21:26:48 +0100
Message-ID: <CAA93jw5bb48sNt_nhKx2O-Sxjzzi7gvfXE6YRgxkYZxEMru0HA@mail.gmail.com>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	<1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325867504.2911.23.camel@edumazet-laptop>
	<CAA93jw7024Ejncj_Gjg9jcQF=HTERkc0dSCrVKrv7XJfELryow@mail.gmail.com>
	<1325869679.2911.27.camel@edumazet-laptop>
	<4F073DD5.6000006@hp.com>
	<1325878415.2911.42.camel@edumazet-laptop>
	<4F074EEA.4090905@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Kathleen Nichols <nichols@pollere.com>,
	Jim Gettys <jg@freedesktop.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41070 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932638Ab2AFU0t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 15:26:49 -0500
Received: by iaeh11 with SMTP id h11so3110419iae.19
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 12:26:48 -0800 (PST)
In-Reply-To: <4F074EEA.4090905@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2012 at 8:43 PM, Rick Jones <rick.jones2@hp.com> wrote:
> On 01/06/2012 11:33 AM, Eric Dumazet wrote:
>>
>> Le vendredi 06 janvier 2012 =E0 10:30 -0800, Rick Jones a =E9crit :
>>
>>> netperf nitpick :) =A0While I doubt that Dave Taht is running it th=
at way,
>>> one can have multiple requests in flight on a single _RR test via t=
he
>>> test-specific -b<additionaltrans> =A0option. =A0That option is enab=
led by
>>> default (--enable-burst on the configure) in 2.5.0 and later.
>>
>>
>> Ah Rick, I dont think we can tune IP_TOS with netperf -t UDP_{STREAM=
|
>> RR} ?
>>
>> I ask because it could be a good thing to set ECT(0) on datagrams to
>> check our ECN capabilities and get in the final report from receiver=
 a
>> count/percentage of CE frames.

=46or other apps than netperf, being able to see this stuff in iptables
(ip6tables) might be helpful. Did this kernel patch series make it?

http://comments.gmane.org/gmane.comp.security.firewalls.netfilter.devel=
/41139


>
> Funny you should mention that :) =A0In the top-of-trunk (perhaps it i=
s in
> 2.5.0 too, I do not recall) there is the global -Y option:
>
> $ src/netperf -Y
> src/netperf: option requires an argument -- 'Y'
>
> Usage: netperf [global options] -- [test options]
>
> Global options:
> ...
> =A0 =A0-y local,remote =A0 Set the socket priority
> =A0 =A0-Y local,remote =A0 Set the IP_TOS. Use hexadecimal.
>
> So long as you either use the omni code directly, or indirectly by no=
t
> undoing WANT_MIGRATION those should work - for some definition of wor=
k
> anyway...I would not be surprised to learn there are bugs in the supp=
ort.

Also in top of netperf trunk is a mode to be able to exercise different=
 TCP
congestion control algorithms. I was mostly fiddling with westwood, tcp=
-lp and
tcp-ledbat v1 ( https://github.com/silviov/TCP-LEDBAT )

" The output selectors are LOCAL_CONG_CONTROL and
   REMOTE_CONG_CONTROL and setting is via the test-specific -K option."

I also have a rsync patch for priority, diffserv and congestion control
floating about...

I'm a little vague as to whether your related kernel patch for inheriti=
ng
the congestion algorithm made it in?

I note that netperf trunk breaks backward compatibility with
netperf 2.5.

> However, there is nothing presently in the netperf code to cause any
> *individual* send to be so marked independently of the others.

Heh.

>
> happy benchmarking,
>
> rick jones



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
