From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: new link failing on duplicate names in different namespaces
Date: Wed, 25 Feb 2015 17:26:35 +0100
Message-ID: <54EDF7BB.2060809@6wind.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:39726 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbbBYQ0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 11:26:39 -0500
Received: by wggx12 with SMTP id x12so4726717wgg.6
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 08:26:37 -0800 (PST)
In-Reply-To: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/02/2015 01:48, Eugene Yakubovich a =C3=A9crit :
> Hello,
>
> rtnetlink's RTM_NEWLINK allows for specifying the network namespace i=
n
> which the link is to be created via IFLA_NET_NS_PID or IFLA_NET_NS_FD=
=2E
> This not only saves a user a call to move the link into the target
> namespace, it can avoid a potential ifname conflict. For example, if
> creating eth0 in another namespace and the current one already has
> eth0.
>
> Unfortunately, this is not the current behavior. If the user specifie=
s
> IFLA_IFNAME, leaves ifinfomsg.ifi_index unspecified and sets
> NLM_F_EXCL flag, as in the case of creating a new link, the call will
> fail with EEXIST in cases where there's a name conflict.
>
> rtnl_newlink() will:
>
> if (ifname[0])
>      dev =3D __dev_get_by_name(net, ifname);
Yes, it seems that this should be done in "dest_net" or "link_net".
