From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Mon, 25 May 2015 15:09:54 +0200
Message-ID: <55631F22.90903@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com> <874mnn9t12.fsf@x220.int.ebiederm.org> <555F969B.3090706@ahsoftware.de> <5562D315.9070405@6wind.com> <5562FFB0.40708@ahsoftware.de>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:35840 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbbEYNJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 09:09:59 -0400
Received: by wgbgq6 with SMTP id gq6so72774190wgb.3
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 06:09:57 -0700 (PDT)
In-Reply-To: <5562FFB0.40708@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/05/2015 12:55, Alexander Holler a =C3=A9crit :
> Am 25.05.2015 um 09:45 schrieb Nicolas Dichtel:
>> Le 22/05/2015 22:50, Alexander Holler a =C3=A9crit :
>
>>> First I think if NETLINK_LISTEN_ALL_NSID is enabled, a dump
>>> of the interfaces through RTM_GETLINK together with NLM_F_DUMP and
>>> NLM_F_REQUEST should return all interfaces of all reachable namespa=
ces.
>> This option is only for 'listening', ie spontaneous notifications fr=
om the
>> kernel. It does nothing for request.
>
> The problem is that you need informations about the affected interfac=
es. E.g. if
> you receive an NEWADDR or NEWROUTE for some interface (indicated by t=
he index of
> the interface) in a(nother) namespace, how do you get informations ab=
out that
> interface, if not by a dump which includes the interfaces of these na=
mespaces
> too? Without knowledge about the interface, these messages are not ve=
ry usable. ;)
Yes, this is the right things.

Usually, a daemon opens a socket to listen netlink event. Then, it open=
s
another netlink socket to dump the configuration (interfaces, addresses=
,
routes, etc.) and fill its internal structures. Starting from that poin=
t, for
most of configuration parameters, it doesn't need anymore to do dumps a=
nd thus
it can close the second socket. This allows your daemon to have only on=
e socket
to monitor a set a netns.
Look at iproute for example, it starts by dumping all interfaces before
executing the specified command.

>
>> Not sure to follow you. veth0 sits in the current netns (let's say
>> init_net)
>> and veth1 in netns1.
>> So, when you dump veth0 in init_net, its link-netnsid is set to the =
id of
>> netns1 in init_net. And when you dump veth1 in netns1, it's link-net=
nsid
>> is set
>> to the id of init_net in netns1.
>
> I've misunderstood the meaning of IFLA_LINK_NETNSID. I thought it ind=
icates the
> namespace an interface lives in, but it indicates the namespace it is=
 linked too.
Yes.

>
> I've also thought that the NETNSID is a global unique identifier of a=
 namespace,
> which seems to be wrong too. While I still not have read through all =
the
> sources, the other comments are suggesting that the NSID is just an I=
D which is
> unique only in one namespace, or in other words, every namespace has =
its own set
> of nsids. I'm not sure if I'm now right with that assumption, but tha=
t's what I
> now think after the responses to my mail. ;)
Right, nsid are local to a netns. This allows to migrate a container. W=
ith a
global id, that won't be possible. ifindex are local for the exact same=
 purpose.

>
> So to conclude, I've now scheduled support for namespaces to a far la=
ter point.
> It doesn't seem to be as easy as I've thought after having read the i=
ntroductory
> mail of your patch series. ;)
The main goal of the series was to improve scalability ;-)


Regards,
Nicolas
