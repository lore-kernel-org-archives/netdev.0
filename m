From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: What are the intended semantics of IFLA_LINK_NETNSID?
Date: Thu, 26 Feb 2015 09:55:56 +0100
Message-ID: <54EEDF9C.20302@6wind.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>	<54EDF7BB.2060809@6wind.com> <871tldstju.fsf_-_@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:37037 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbbBZI4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 03:56:00 -0500
Received: by wghk14 with SMTP id k14so8671588wgh.4
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 00:55:59 -0800 (PST)
In-Reply-To: <871tldstju.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/02/2015 20:03, Eric W. Biederman a =C3=A9crit :
>
> Reading through the code of rtnl_newlink I am perplexed with what you=
r
> intended semantics of IFLA_LINK_NETNSID are supposed to be.
>
> My expectation was something with the same semantics IFLA_NET_NS_PID =
and
> IFLA_NET_NS_FD just a different data representation and something tha=
t
> could be used in more netlink messages, so you could report the netwo=
rk
> namespace where the other end of a tunnel or the the network namespac=
e
> of an underlying device is.
>
> Being very slow I would expect that ILFA_LINK_NETNSID would replace
> dest_net or possibly net in rtnl_newlink but it does not replace eith=
er
> of those completely.  Which causes me to think that the implementatio=
n
> of IFLA_LINK_NETNSID in rtnl_newlink is broken.
>
> I suspect the correct fix for rtnl_newlink is to just use
> IFLA_LINK_NETNSID in rtnl_link_get_net and have it be an alternative =
way
> of setting dest_net.  But you may intend some different semantics tha=
t
> I don't understand.
ILFA_LINK_NETNSID is used to point to the i/o netns of the interface, i=
e the
opposite netns of dest_net.
The interface is first created in link_net and moved at the end in dest=
_net.

IP tunnels interfaces (ipip, sit, ip6_tunnels, gre[v6]) does not use sr=
c_net,
thus when you create an ipip interface by specifying an attribute
IFLA_NET_NS_PID it will result to an interface which is not across two =
netns but
only in the netns pointed by IFLA_NET_NS_PID. If you use IFLA_LINK_NETN=
SID, it
allows you to create this kind of x-netns interfaces.
In fact, the goal of this attribute is to replace the two following com=
mand by
only one:
ip link add foo ...
ip link set foo netns bar
=3D> ip link add foo link-netnsid barID


Regards,
Nicolas
