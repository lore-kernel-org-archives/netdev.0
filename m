From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: occasionally corrupted network stats in /proc/net/dev
Date: Mon, 14 Jan 2008 18:38:58 +0100
Message-ID: <478B9E32.4020902@cosmosbay.com>
References: <478B99E6.2050800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mark Seger <Mark.Seger@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([193.252.22.29]:49325 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178AbYANVPJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 16:15:09 -0500
Received: from smtp20.orange.fr (mwinf2016 [172.22.130.116])
	by mwinf2015.orange.fr (SMTP Server) with ESMTP id 5AAA21C0C3A8
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 18:39:44 +0100 (CET)
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2016.orange.fr (SMTP Server) with ESMTP id 0F7161C000B6
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 18:39:02 +0100 (CET)
In-Reply-To: <478B99E6.2050800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Seger a =E9crit :
> I had posted the following on linux-net and haven't see any responses=
=20
> possibly because nobody had any or that list is obsolete.  I have bee=
n=20
> told this is the current list for everything networking on linux so I=
=20
> thought I'd try again...
>
> I suspect the answer will be that it is what it is, but here's the=20
> deal.  I have a tool I use for monitoring network traffic among other=
=20
> things - see http://collectl.sourceforge.net/ - and one of its=20
> benefits  is that you can run it continuously as a daemon (similar to=
=20
> sar) and generate data in a format suitable for plotting.  This means=
=20
> that you can automate your entire network monitoring infrastructure a=
t=20
> fairly fine granularity, down to second if you like.  Actually=20
> 1-second level monitoring will provide incorrect data on earlier=20
> kernels because the stats aren't updated on 1 second boundaries and=20
> you need to monitor at an interval of 0.9765 seconds, but that's a=20
> different story which is explained at=20
> http://collectl.sourceforge.net/NetworkStats.html
>
> But more importantly, I've found that occasionally (not that often)=20
> there is bogus data reported from /proc/net/dev.  While I don't have =
a=20
> lot of details on this it seems to only show up in 64 bit kernels. =20
> Look at the following samples taken at 1 second intervals:
>
> eth0:135115809 1024897    0    0    0     0          0         9=20
> 135458926  910340    0    0    0     0       0          0
> eth0:135118023 1024923    0    0    0     0          0         9=20
> 135460952  910363    0    0    0     0       0          0
> eth0:        0  884620    0    0    0     0          0    909397  =20
> 9687563 1049736    0    0    0     0       0          0
> eth0:135121189 1024957    0    0    0     0          0         9=20
> 135464222  910400    0    0    0     0       0          0
> eth0:135129565 1024995    0    0    0     0          0         9=20
> 135473687  910435    0    0    0     0       0          0
>
> see the middle sample?  When I look at the change between samples it=20
> generates a really big number since the difference is assumed to be=20
> caused a counter wrapping.  The problem is it's not always=20
> straightforward when there is bad data.  For example if the original=20
> and bogus values are close enough it's not even clear there is a prob=
lem.
>
> So the obvious question is, is there any way to prevent the bogus dat=
a=20
> from getting reported?   If not, is there any way to set the values t=
o=20
> something to indicate that the correct values can't be determined? =20
> Clearly this problem would be visible to any tool that looks at /proc=
=20
> but since many tools are not automated or don't take it to the level =
I=20
> do, nobody probably notices.  As for the counter update frequency,=20
> even though they now appear to be updated closer to a 1 second=20
> boundary it also means tools that can monitor at sub-second intervals=
=20
> will report incorrect data since the counters only change once a seco=
nd.
What is the NIC used for eth0 (and driver name)

Which version of linux kernel do you run ?




