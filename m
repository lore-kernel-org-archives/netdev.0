From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Wed, 19 Aug 2015 18:33:14 +0200
Message-ID: <55D4AFCA.7080300@6wind.com>
References: <87fv3ier4s.fsf@zoro.exoscale.ch>	<1439966648-26195-1-git-send-email-vincent@bernat.im>	<1439966648-26195-2-git-send-email-vincent@bernat.im>	<20150819130013.1a847627@griffin> <87bne38oj7.fsf@zoro.exoscale.ch>	<20150819143800.6863fa3b@griffin> <8737zf8mwd.fsf@zoro.exoscale.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Vincent Bernat <vincent@bernat.im>, Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36427 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbbHSQdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:33:37 -0400
Received: by pdbmi9 with SMTP id mi9so3330368pdb.3
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 09:33:37 -0700 (PDT)
In-Reply-To: <8737zf8mwd.fsf@zoro.exoscale.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/08/2015 14:48, Vincent Bernat a =C3=A9crit :
>   =E2=9D=A6 19 ao=C3=BBt 2015 14:38 +0200, Jiri Benc <jbenc@redhat.co=
m> :
>
>>> That's the main goal of this patch: advertising the peer link as
>>> IFLA_LINK attribute triggers an infinite loop in userland software =
when
>>> they follow iflink to discover network devices topology. iflink has
>>> always been the index of a lower device. If a sysfs symbolic link i=
s not
>>> good enough, I can propose a new IFLA_PEER attribute instead.
>>
>> This would cause regression and break applications for those of us w=
ho
>> started relying on the netnsid feature to match interfaces across ne=
t
>> name spaces.
>
> Yes. Unfortunately.
>
>> This is tough. If you're going to do such thing, you would at least
>> need to also introduce IFLA_PEER_NETNSID.
Probably better to introduce veth netlink attribute then, something lik=
e
IFLA_VETH_PEER and keeps IFLA_LINK_NETNSID.

>
> Yes I can.
>
> In my opinion, the change of semantics of IFLA_LINK is a break of
> API. However, I can live with it since it's easy to workaround it. It
> just seemed easier to start the discussion with a patch.
>
I also don't know what is the best way to handle this. veth advertises
its peer via IFLA_LINK since 4.1, so it's too late to change it for thi=
s
release.
