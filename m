From: Josef Bacik <jbacik@fb.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Fri, 9 Dec 2016 01:01:02 +0000
Message-ID: <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
         <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
         <1481233016.11849.1@smtp.office365.com>,<1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41410 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753547AbcLIBBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 20:01:10 -0500
In-Reply-To: <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Dec 8, 2016, at 7:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> On Thu, 2016-12-08 at 16:36 -0500, Josef Bacik wrote:
>>=20
>> We can reproduce the problem at will, still trying to run down the=20
>> problem.  I'll try and find one of the boxes that dumped a core and get=
=20
>> a bt of everybody.  Thanks,
>=20
> OK, sounds good.
>=20
> I had a look and :
> - could not spot a fix that came after 4.6.=20
> - could not spot an obvious bug.
>=20
> Anything special in the program triggering the issue ?
> SO_REUSEPORT and/or special socket options ?
>=20

So they recently started using SO_REUSEPORT, that's what triggered it, if t=
hey don't use it then everything is fine.

I added some instrumentation for get_port to see if it was looping in there=
 and none of my printk's triggered.  The softlockup messages are always on =
the inet_bind_bucket lock, sometimes in the process context in get_port or =
in the softirq context either through inet_put_port or inet_kill_twsk.  On =
the box that I have a coredump for there's only one processor in the inet c=
ode so I'm not sure what to make of that.  That was a box from last week so=
 I'll look at a more recent core and see if it's different.  Thanks,

Josef=
