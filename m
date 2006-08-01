From: Oumer Teyeb <oumer@kom.aau.dk>
Subject: Re: Linux TCP in the presence of delays or drops...
Date: Tue, 01 Aug 2006 13:56:33 +0200
Message-ID: <44CF4171.8050205@kom.aau.dk>
References: <44CD0D58.7050207@kom.aau.dk> <44CE42A8.7090305@kom.aau.dk> <Pine.LNX.4.58.0608011041090.3911@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaz.kom.auc.dk ([130.225.51.10]:17304 "EHLO zaz.kom.auc.dk")
	by vger.kernel.org with ESMTP id S1422785AbWHAL4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 07:56:38 -0400
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
In-Reply-To: <Pine.LNX.4.58.0608011041090.3911@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Ilpo for the info!

I am trying out the tests now using timestamps only and without FRTO,=20
and vice versa and see if there is any change.
Actually, I have also noticed in some of the traces also this behaviour=
=20
of FRTO where it mistook a loss as spurious which leads to further=20
performance degradtion. but I was also using timestamps, so I dont know=
=20
if it also occurs without timestamps.  I will try it out and let you=20
know. I will send you the traces I just mentioned (FRTO+timestamps=20
leading to a loss being mistaken for a spurious one..)..

Regards,
Oumer

Ilpo J=E4rvinen wrote:

>On Mon, 31 Jul 2006, Oumer Teyeb wrote:
>
> =20
>
>>-If multiple timeouts occur for one packet then even if we are using =
the
>>timestamp option or FRTO TCP linux is not able to detect spurious
>>retransmissions... and TCP linux is able to detect spurious retransmi=
ssions
>>only for a single timeout for one packet or fast retransmissions that=
 are
>>caused by duplicate ACK reception.....I have some traces that show th=
is
>>behaviour, let me know if you are interested.
>>   =20
>>
>
>I have come across this same issue. I can confirm that multiple RTOs i=
s=20
>not handled correctly. But there are some other issues in FRTO as=20
>well... nothing extremely dangerous though. In one of the cases, the=20
>current FRTO algorithm could miss real losses, but you luckily need to=
 be=20
>quite clever to trigger that, and due to very conservative response us=
ed=20
>in case spurious RTO is detected, it has no significant danger in it e=
ven=20
>then. The other flaws cause too conservative behavior.
> =20
>

>We have a set of fixes to F-RTO, but part of them have not yet been=20
>tested. Since the fixes include 4-5 independent changes to handle also=
=20
>rare cases, it takes some time to test. Besides, I'll probably have to=
=20
>talk with Pasi Sarolahti (author of FRTO) on couple of interpretation=20
>issues in RFC4138 as soon as his vacation ends (mid August if I rememb=
er=20
>correctly) to verify some of the changes.
>
>I expect that I'll get some actual results after two weeks or so... I =
case=20
>you're are in hurry and are interested on the fixes, I could prepare a=
n=20
>independent patch quite soon and release it (untested) on our projects=
 web=20
>site (if you are interested, ask off-list so that we don't bother othe=
rs=20
>:-)). But the kernel inclusion of the fixes should IMO wait at least u=
ntil=20
>I get some decent test cases analyzed, which will take at least two we=
eks=20
>or so due to my schedule.
>
> =20
>

>>-In the cases where TCP timestamp or FRTO is not able to detect spuri=
ous
>>retransmissions, the performance degrades even more than when TCP tim=
estamp
>>or FRTO option are not used....
>>   =20
>>
>
>That's one of the FRTO "features", we have a fix (I cannot say about=20
>timestamps since we've been running our tests without tstamps for year=
s).
> =20
>
