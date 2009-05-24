From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Mon, 25 May 2009 00:47:39 +0200
Message-ID: <4A19CE8B.3070302@cosmosbay.com>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb> <20090524213744.GG24757@kvack.org> <4A19BF39.4000305@cosmosbay.com> <20090524214433.GH24757@kvack.org> <4A19C50B.9040304@cosmosbay.com> <20090524221240.GI24757@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38014 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbZEXWrx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 18:47:53 -0400
In-Reply-To: <20090524221240.GI24757@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
> On Mon, May 25, 2009 at 12:07:07AM +0200, Eric Dumazet wrote:
>> Maybe your HZ is too low ? Changing to 1000 HZ helps a lot
>=20
> HZ is set to 1000.  I turned off CONFIG_NO_HZ
>=20
>> Also your hotplug config might do strange things at device removal ?
>=20
> If it were CPU bound, maybe, but this behaviour is tied to the kernel=
=20
> version in use.
>=20
>> What distro do you use ?
>=20
> It's an older Fedora 7 install inside kvm on a Fedora 10 host running=
=20
> 2.6.30-rc7.
>=20

OK thanks

I switched HZ from 250 to 1000 and got :

time ip link del vlan.899

real    0m0.011s
user    0m0.000s
sys     0m0.002s

There is a strong dependancy against HZ
BTW, I am using TREE_RCU

# RCU Subsystem
# CONFIG_CLASSIC_RCU is not set
CONFIG_TREE_RCU=3Dy
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_TRACE=3Dy
CONFIG_RCU_FANOUT=3D32
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_TREE_RCU_TRACE=3Dy
# CONFIG_PREEMPT_RCU_TRACE is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set


