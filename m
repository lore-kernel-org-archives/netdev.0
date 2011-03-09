From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Wed, 9 Mar 2011 13:12:03 -0800
Message-ID: <AANLkTimpLWoSB2H9PObxwK1iGkFBWQZMw=1kTP9BA7qb@mail.gmail.com>
References: <il4vur$3ka$1@dough.gmane.org> <20110308111011.GA27967@xanadu.blop.info>
 <4D764AAC.30302@ncsu.edu> <20110308.114346.48506864.davem@davemloft.net>
 <20110308152103.714f5f05@nehalam> <4D76D851.4050600@ncsu.edu>
 <20110309065319.GA23740@xanadu.blop.info> <20110309095659.1373c296@s6510>
 <20110309182505.GA25272@xanadu.blop.info> <20110309120120.5016cab5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucas Nussbaum <lucas.nussbaum@loria.fr>,
	Injong Rhee <rhee@ncsu.edu>,
	David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, sangtae.ha@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:30633 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318Ab1CIVRe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 16:17:34 -0500
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p29LHSY7006147
	for <netdev@vger.kernel.org>; Wed, 9 Mar 2011 13:17:32 -0800
Received: from gyg10 (gyg10.prod.google.com [10.243.50.138])
	by kpbe16.cbf.corp.google.com with ESMTP id p29LBrUe030609
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 9 Mar 2011 13:12:23 -0800
Received: by gyg10 with SMTP id 10so534531gyg.7
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2011 13:12:23 -0800 (PST)
In-Reply-To: <20110309120120.5016cab5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 9, 2011 at 12:01 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Wed, 9 Mar 2011 19:25:05 +0100
> Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:
>
>> On 09/03/11 at 09:56 -0800, Stephen Hemminger wrote:
>> > On Wed, 9 Mar 2011 07:53:19 +0100
>> > Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:
>> >
>> > > On 08/03/11 at 20:30 -0500, Injong Rhee wrote:
>> > > > Now, both tools can be wrong. But that is not catastrophic sin=
ce
>> > > > congestion avoidance can kick in to save the day. In a pipe wh=
ere no
>> > > > other flows are competing, then exiting slow start too early c=
an
>> > > > slow things down as the window can be still too small. But tha=
t is
>> > > > in fact when delays are most reliable. So those tests that say=
 bad
>> > > > performance with hystart are in fact, where hystart is suppose=
d to
>> > > > perform well.
>> > >
>> > > Hi,
>> > >
>> > > In my setup, there is no congestion at all (except the buffer bl=
oat).
>> > > Without Hystart, transferring 8 Gb of data takes 9s, with CUBIC =
exiting
>> > > slow start at ~2000 packets.
>> > > With Hystart, transferring 8 Gb of data takes 19s, with CUBIC ex=
iting
>> > > slow start at ~20 packets.
>> > > I don't think that this is "hystart performing well". We could j=
ust as
>> > > well remove slow start completely, and only do congestion avoida=
nce,
>> > > then.
>> > >
>> > > While I see the value in Hystart, it's clear that there are some=
 flaws
>> > > in the current implementation. It probably makes sense to disabl=
e
>> > > hystart by default until those problems are fixed.
>> >
>> > What is the speed and RTT time of your network?
>> > I think you maybe blaming hystart for other issues in the network.
>>
>> What kind of issues?
>>
>> Host1 is connected through a gigabit ethernet LAN to Router1
>> Host2 is connected through a gigabit ethernet LAN to Router2
>> Router1 and Router2 are connected through an experimentation network=
 at
>> 10 Gb/s
>> RTT between Host1 and Host2 is 11.3ms.
>> The network is not congested.
>
> By my calculations (1G * 11.3ms) gives BDP of 941 packets which means
> CUBIC would ideally exit slow start at 900 or so packets. Old CUBIC
> slowstrart of 2000 packets means there is huge overshoot which means
> large packet loss burst which would cause a large CPU load on receive=
r
> processing SACK.
It's not clear from Lucas's report that the hystart is exiting when
cwnd=3D2000 or when sender has sent 2000 packets.
Lucas could you clarify?

>
> I assume you haven't done anything that would disable RFC1323
> support like turn off window scaling or tcp timestamps.
>
>
> --
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
