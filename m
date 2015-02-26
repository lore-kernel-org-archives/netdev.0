From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: What are the intended semantics of IFLA_LINK_NETNSID?
Date: Thu, 26 Feb 2015 15:52:40 +0100
Message-ID: <54EF3338.8000409@6wind.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>	<54EDF7BB.2060809@6wind.com> <871tldstju.fsf_-_@x220.int.ebiederm.org>	<54EEDF9C.20302@6wind.com> <87wq34okb9.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:44974 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbbBZOwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:52:43 -0500
Received: by wesk11 with SMTP id k11so11440274wes.11
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 06:52:42 -0800 (PST)
In-Reply-To: <87wq34okb9.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/02/2015 14:48, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
[snip]
>> The interface is first created in link_net and moved at the end in d=
est_net.
>>
>> IP tunnels interfaces (ipip, sit, ip6_tunnels, gre[v6]) does not use=
 src_net,
>
> I am pretty certain that is simply something that was overlooked when
> cross network namespace support was added to those network device typ=
es.
> Right now I would be surprised if anything in userspace cares, so we =
can
> probably just change those device types to look at src_net from newli=
nk.
At least, depending of the interface type, the behavior is not the same=
=2E Thus,
making all interfaces consistent seems good.

>
> Certainly for our sanity in maintaining rtnl_newlink finding a way to
> make that change would be preferable.  Even if we ultimately have to =
add
> a flag that says only make src_net different from dev->net when
> IFLA_LINK_NETNSID is passed.
A flag is probably not needed, it's just a matter of passing src_net th=
rough
the functions that create the tunnel device.

>
> As making that change allows much more consistency in the code and
> allows us to get rid of an unnecessary dev_change_net_namespace.
Yes, I add this dev_change_net_namespace() to be independant of the int=
erface
implementation (and thus beeing consistent whatever the interface type =
is used).


Nicolas
