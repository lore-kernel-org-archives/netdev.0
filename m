From: Erik Grinaker <erik@bengler.no>
Subject: Re: TCP connection issues against Amazon S3
Date: Tue, 6 Jan 2015 21:04:58 +0000
Message-ID: <3F608393-E5F1-4647-81BF-C6C740100934@bengler.no>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no> <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com> <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no> <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com> <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no> <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com> <03FC652E-AA01-42C7-BD52-019B6D922A9C@bengler.no> <CAK6E8=cP0BFUob5MVj9M0hC0efgRnUY=JMUPKee+v-4TLvHBgg@mail.gmail.com> <76DC89D1-CFCE-44B7-994E-4349FEEDEFA6@bengler.no> <1420575216.5947.12.camel@edumazet-glaptop2.roam.corp.google.com> <4DA8529D-4EEC-42DA-89B0-DC7746DB2B10@bengler.no>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:59769 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752933AbbAFVFA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 16:05:00 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 3EA4320BF1
	for <netdev@vger.kernel.org>; Tue,  6 Jan 2015 16:05:00 -0500 (EST)
In-Reply-To: <4DA8529D-4EEC-42DA-89B0-DC7746DB2B10@bengler.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 06 Jan 2015, at 20:26, Erik Grinaker <erik@bengler.no> wrote:
>=20
>>=20
>> On 06 Jan 2015, at 20:13, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
>>=20
>> On Tue, 2015-01-06 at 19:42 +0000, Erik Grinaker wrote:
>>=20
>>> The transfer on the functioning Netherlands server does indeed use =
SACKs, while the Norway servers do not.
>>>=20
>>> For what it=E2=80=99s worth, I have made stripped down pcaps for a =
single failing transfer as well as a single functioning transfer in the=
 Netherlands:
>>>=20
>>> http://abstrakt.bengler.no/tcp-issues-s3-failure.pcap.bz2
>>> http://abstrakt.bengler.no/tcp-issues-s3-success-netherlands.pcap.b=
z2
>>>=20
>>=20
>> Although sender seems to be reluctant to retransmit, this 'failure' =
is
>> caused by receiver closing the connection too soon.
>>=20
>> Are you sure you do not ask curl to setup a very small completion
>> timer ?
>=20
> For testing, I am using Curl with a 30 second timeout. This may well =
be a bit short, but the point is that with the older kernel I could run=
 thousands of requests without a single failure (generally the requests=
 would finish within seconds), while with the newer kernel about 5% of =
requests will time out (the rest complete within seconds).
>=20
>> 12:41:00.738336 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [=
=2E], seq 767221:768681, ack 154, win 127, length 1460
>> 12:41:00.738346 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [=
=2E], ack 736561, win 1877, length 0
>> 12:41:05.227150 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [=
=2E], seq 736561:738021, ack 154, win 127, length 1460
>> 12:41:05.227250 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [=
=2E], ack 745321, win 1882, length 0
>> 12:41:05.278287 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [=
=2E], seq 768681:770141, ack 154, win 127, length 1460
>> 12:41:05.278354 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [=
=2E], ack 745321, win 1888, length 0
>> 12:41:05.278421 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [=
=2E], seq 770141:771601, ack 154, win 127, length 1460
>> 12:41:05.278429 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [=
=2E], ack 745321, win 1894, length 0
>> 12:41:14.257102 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [=
=2E], seq 745321:746781, ack 154, win 127, length 1460
>> 12:41:14.257154 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [=
=2E], ack 746781, win 1900, length 0
>> 12:41:14.308117 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [=
=2E], seq 771601:773061, ack 154, win 127, length 1460
>> 12:41:14.308227 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [=
=2E], ack 746781, win 1905, length 0
>> 12:41:14.308387 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [=
=2E], seq 773061:774521, ack 154, win 127, length 1460
>> 12:41:14.308397 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [=
=2E], ack 746781, win 1911, length 0
>>=20
>> -> Here receiver sends a FIN, because application closed the socket =
(or died)
>> 12:41:23.237156 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [=
=46.], seq 154, ack 746781, win 1911, length 0
>> 12:41:23.289805 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [=
=2E], seq 746781:748241, ack 155, win 127, length 1460
>> 12:41:23.289882 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [=
R], seq 505782802, win 0, length 0
>>=20
>> Anyway, getting decent speed without SACK is going to be hard.
>=20
> Yes, I am not sure why the sender (S3) disables SACK on my Norwegian =
servers (across ISPs), while it enables SACK on my server in the Nether=
lands. They run the same kernel and configuration. I will have to look =
into it more closely tomorrow.

It turns out the Norway and Netherlands servers were resolving differen=
t loadbalancers. The ones I reached in Norway did not support SACKs, wh=
ile the ones in the Netherlands did. Going directly to a SACK-enabled I=
P fixes the problem.

This still doesn=E2=80=99t explain why it works with older kernels, but=
 not newer ones. I=E2=80=99m thinking it=E2=80=99s probably some minor =
change, which gets amplified by the lack of SACKs on the loadbalancer. =
Anyway, I=E2=80=99ll bring it up with Amazon.

Many thanks for your help, everyone.