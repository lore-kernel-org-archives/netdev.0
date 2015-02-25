From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: new link failing on duplicate names in different namespaces
Date: Wed, 25 Feb 2015 11:44:05 -0600
Message-ID: <8761apubru.fsf@x220.int.ebiederm.org>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
	<54EDF7BB.2060809@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:39781 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbbBYRre convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:47:34 -0500
In-Reply-To: <54EDF7BB.2060809@6wind.com> (Nicolas Dichtel's message of "Wed,
	25 Feb 2015 17:26:35 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 25/02/2015 01:48, Eugene Yakubovich a =C3=A9crit :
>> Hello,
>>
>> rtnetlink's RTM_NEWLINK allows for specifying the network namespace =
in
>> which the link is to be created via IFLA_NET_NS_PID or IFLA_NET_NS_F=
D.
>> This not only saves a user a call to move the link into the target
>> namespace, it can avoid a potential ifname conflict. For example, if
>> creating eth0 in another namespace and the current one already has
>> eth0.
>>
>> Unfortunately, this is not the current behavior. If the user specifi=
es
>> IFLA_IFNAME, leaves ifinfomsg.ifi_index unspecified and sets
>> NLM_F_EXCL flag, as in the case of creating a new link, the call wil=
l
>> fail with EEXIST in cases where there's a name conflict.
>>
>> rtnl_newlink() will:
>>
>> if (ifname[0])
>>      dev =3D __dev_get_by_name(net, ifname);
> Yes, it seems that this should be done in "dest_net" or "link_net".

Ugh.  Looking at that code I think the link_net is at best extremely
confusing most likely semantically broken the way it is being
interpreted in rtnl_newlink.  More in another email message.

The original semantics and what seems mostly reasonable because the
network device in some sense lives in multiple network namespaces
as it is being created is that the network device name be unique
in both namespaces.

The code that creates a network devices fundamentally needs to know
about both namespaces network devices like the macvlan driver need
to find their lower devices in the original network namespace.

I think we could possibly remove the restriction for the names of newly
created network devices being unique in both network namespaces but I
don't think the code changes will be trivial.

Eric
