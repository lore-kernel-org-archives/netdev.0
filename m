From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Namespaces and devices
Date: Sun, 23 May 2010 16:04:38 +0200
Message-ID: <4BF935F6.2050907@free.fr>
References: <AANLkTimN8IYQBiot2iBB6XV8dtTGRnHQQ6lKLag5plEm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:41952 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654Ab0EWOEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 10:04:52 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.1/8.13.1) with ESMTP id o4NE4p4J025443
	for <netdev@vger.kernel.org>; Sun, 23 May 2010 14:04:51 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4NE4psP864478
	for <netdev@vger.kernel.org>; Sun, 23 May 2010 16:04:51 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4NE4oqg017212
	for <netdev@vger.kernel.org>; Sun, 23 May 2010 16:04:51 +0200
In-Reply-To: <AANLkTimN8IYQBiot2iBB6XV8dtTGRnHQQ6lKLag5plEm@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/21/2010 06:27 PM, Mart=EDn Ferrari wrote:
> Hi,
>
> Sorry if this is a dumb question, but I couldn't find any
> documentation that matches the current behaviour... So I don't know i=
f
> what I see is what is intended, or if it's a bug.
>
> I would like to know what is the exact behaviour re. devices when a
> netns is destroyed, and which kind of devices can be moved.
>
> According to http://lxc.sourceforge.net/network/configuration.php,
> devices assigned to a netns should move to the main netns when the
> former is destroyed. What I see is that the devices are deleted, at
> least for veth and dummy devices. I also see a bug I previously
> reported that caused an oops in some cases.
>   =20

The documentation on this website is a bit out dated. That was the=20
initial behavior but was changed as the following.

All the virtual devices are destroyed with the network namespace. The=20
destroyable virtual devices are identified when they have the dellink=20
ops defined. If you can do the 'ip link del' command on this device,=20
then this device type will be destroyed by a netns.

About the oops,  was the it "kernel panic when using=20
netns+bridges+tc(netem)" ?

> Also, I have read somewhere (now I cannot find it) that supposedly, I
> should be able to move real devices to a netns, but I always get
> Invalid argument errors.

Yes, that was previously the case with the proof of concept, because=20
sysfs per namespace was enabled. But this feature is not merged upstrea=
m=20
yet (but is on the way), so physical devices are not movable across=20
namespaces.

Hope that helps
   -- Daniel
