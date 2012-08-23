From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: dev: fix the incorrect hold of net namespace's lo
 device
Date: Thu, 23 Aug 2012 11:09:41 +0800
Message-ID: <50359EF5.5080008@cn.fujitsu.com>
References: <1345624262-6554-1-git-send-email-gaofeng@cn.fujitsu.com>  <1345624786.5158.759.camel@edumazet-glaptop>  <5034BBBB.6080307@cn.fujitsu.com> <1345634667.5158.1114.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:25905 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757207Ab2HWDJ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 23:09:28 -0400
In-Reply-To: <1345634667.5158.1114.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B408=E6=9C=8822=E6=97=A5 19:24, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Wed, 2012-08-22 at 19:00 +0800, Gao feng wrote:
>=20
>> Hi Eric
>>
>> I saw your patch and think this patch is clear and doesn't change to=
o much logic.
>>
>> I test your patch, it not fix this problem.
>>
>> In my test case,when moving a net device to another net namespace,
>> Because you patch delete NETDEV_UNREGISTER event from dst_dev_event,
>> we will just put dst entries into the dst garbage list in event
>> NETDEV_DOWN,without call dst_ifdown to change these dst entries' dev=
ice
>> to the lo device,and now this net device belongs to the new net name=
space.
>>
>=20
> Then fix the "moving a net device to another net namespace", instead
> of slowing down other common operations.
>=20

okay, I will send a patch to fix this problem after your patch beeing a=
pplied.

> dev_change_net_namespace() is probably a better place to put your pat=
ch
>=20
>> After the net device beeing moved to another net namespace, I rmmod =
this
>> net device's driver,this will trigger the new added event NETDEV_UNR=
EGISTER_FINISH,
>> so in dst_dev_event,we will change these dst entries's device to the=
 new net
>> namespace's lo device,and this will make the referenct count of the =
new net namespace's
>> lo device incorrect. when we exit the new net namespace,this emg mes=
sage is still exist.
>>
>> Message from syslogd@Donkey at Aug 22 18:50:13 ...
>>  kernel:[ 1161.979036] unregister_netdevice: waiting for lo to becom=
e free. Usage count =3D 1
>>
>> And because net_mutex is locked here,so we can't create new net name=
space.
>>
>>> rcu_barrier() at this place will kill some workloads.
>>>
>>
>> I think this will only add some workloads when unregister a net devi=
ce.
>> Do I miss something?
>=20
> Yes, rcu_barrier() at this point is killing performance, because we h=
old
> RTNL.
>=20
> We worked hard to batch things, your patch is a huge step backward.
>=20

Get it,thanks for your explanation.
