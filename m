From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Tue, 26 May 2015 12:53:11 +0200
Message-ID: <55645097.5000509@ahsoftware.de>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com> <874mnn9t12.fsf@x220.int.ebiederm.org> <555F969B.3090706@ahsoftware.de> <5562D315.9070405@6wind.com> <5562FFB0.40708@ahsoftware.de> <55631F22.90903@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.214.92.142] ([85.214.92.142]:48043 "EHLO mail.ahsoftware.de"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752987AbbEZKyO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 06:54:14 -0400
Received: from wandq.ahsoftware (p4FC36136.dip0.t-ipconnect.de [79.195.97.54])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id 0E04A2C9C1C7
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 12:53:16 +0200 (CEST)
In-Reply-To: <55631F22.90903@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 25.05.2015 um 15:09 schrieb Nicolas Dichtel:
> Le 25/05/2015 12:55, Alexander Holler a =C3=A9crit :
>> Am 25.05.2015 um 09:45 schrieb Nicolas Dichtel:
>>> Le 22/05/2015 22:50, Alexander Holler a =C3=A9crit :
>>
>>>> First I think if NETLINK_LISTEN_ALL_NSID is enabled, a dump
>>>> of the interfaces through RTM_GETLINK together with NLM_F_DUMP and
>>>> NLM_F_REQUEST should return all interfaces of all reachable namesp=
aces.
>>> This option is only for 'listening', ie spontaneous notifications
>>> from the
>>> kernel. It does nothing for request.
>>
>> The problem is that you need informations about the affected
>> interfaces. E.g. if
>> you receive an NEWADDR or NEWROUTE for some interface (indicated by
>> the index of
>> the interface) in a(nother) namespace, how do you get informations
>> about that
>> interface, if not by a dump which includes the interfaces of these
>> namespaces
>> too? Without knowledge about the interface, these messages are not
>> very usable. ;)
> Yes, this is the right things.
>
> Usually, a daemon opens a socket to listen netlink event. Then, it op=
ens
> another netlink socket to dump the configuration (interfaces, address=
es,
> routes, etc.) and fill its internal structures. Starting from that
> point, for
> most of configuration parameters, it doesn't need anymore to do dumps
> and thus
> it can close the second socket. This allows your daemon to have only =
one
> socket
> to monitor a set a netns.
> Look at iproute for example, it starts by dumping all interfaces befo=
re
> executing the specified command.

Hmm, sounds like we're talking in different rooms about the same thing=20
in regard to the dump. ;)

I just wanted to explain why I think this series misses the (extended)=20
dump which includes all interfaces (those of other namespaces too).

How does one use NETLINK_LISTEN_ALL_NSID without beeing able to dump al=
l=20
the interfaces of namespaces your patch series might send messages for?

The only way I currently see, is to start the listening part before any=
=20
namespace is created. Doing so, it can fill it's internal structures=20
with the RTM_NEWLINK messages (besides that missing one for lo). But ho=
w=20
do you get these RTM_NEWLINK messages for already created namespaces an=
d=20
their interfaces, if not by a dump?

Regards,

Alexander Holler
