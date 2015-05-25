From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Mon, 25 May 2015 12:55:44 +0200
Message-ID: <5562FFB0.40708@ahsoftware.de>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com> <874mnn9t12.fsf@x220.int.ebiederm.org> <555F969B.3090706@ahsoftware.de> <5562D315.9070405@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:44603 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbbEYK4K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 06:56:10 -0400
Received: from wandq.ahsoftware (p4FC3764E.dip0.t-ipconnect.de [79.195.118.78])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id C2FFF2C9C1C8
	for <netdev@vger.kernel.org>; Mon, 25 May 2015 12:56:07 +0200 (CEST)
In-Reply-To: <5562D315.9070405@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 25.05.2015 um 09:45 schrieb Nicolas Dichtel:
> Le 22/05/2015 22:50, Alexander Holler a =C3=A9crit :

>> First I think if NETLINK_LISTEN_ALL_NSID is enabled, a dump
>> of the interfaces through RTM_GETLINK together with NLM_F_DUMP and
>> NLM_F_REQUEST should return all interfaces of all reachable namespac=
es.
> This option is only for 'listening', ie spontaneous notifications fro=
m the
> kernel. It does nothing for request.

The problem is that you need informations about the affected interfaces=
=2E=20
E.g. if you receive an NEWADDR or NEWROUTE for some interface (indicate=
d=20
by the index of the interface) in a(nother) namespace, how do you get=20
informations about that interface, if not by a dump which includes the=20
interfaces of these namespaces too? Without knowledge about the=20
interface, these messages are not very usable. ;)

> Not sure to follow you. veth0 sits in the current netns (let's say
> init_net)
> and veth1 in netns1.
> So, when you dump veth0 in init_net, its link-netnsid is set to the i=
d of
> netns1 in init_net. And when you dump veth1 in netns1, it's link-netn=
sid
> is set
> to the id of init_net in netns1.

I've misunderstood the meaning of IFLA_LINK_NETNSID. I thought it=20
indicates the namespace an interface lives in, but it indicates the=20
namespace it is linked too.

I've also thought that the NETNSID is a global unique identifier of a=20
namespace, which seems to be wrong too. While I still not have read=20
through all the sources, the other comments are suggesting that the NSI=
D=20
is just an ID which is unique only in one namespace, or in other words,=
=20
every namespace has its own set of nsids. I'm not sure if I'm now right=
=20
with that assumption, but that's what I now think after the responses t=
o=20
my mail. ;)

So to conclude, I've now scheduled support for namespaces to a far late=
r=20
point. It doesn't seem to be as easy as I've thought after having read=20
the introductory mail of your patch series. ;)

Regards,

Alexander Holler
