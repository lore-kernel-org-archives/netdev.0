From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Pv-drivers] rps and pvdrivers
Date: Sat, 04 Sep 2010 08:51:35 +0200
Message-ID: <1283583095.2320.11.camel@edumazet-laptop>
References: <AANLkTimrHh1ZasO=GWUOT9YJbu2EqeAx6OkRXPUSSNJ6@mail.gmail.com>
	 <8B1F619C9F5F454E81D90D3C161698D70337A49A5A@EXCH-MBX-3.vmware.com>
	 <AANLkTi=o8GYdLyY8EzfRno39O2kUSh3wSp9raZCUp_Zz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bhavesh Davda <bhavesh@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"therbert@google.com" <therbert@google.com>
To: Chetan Loke <chetanloke@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61733 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072Ab0IDGvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 02:51:40 -0400
Received: by fxm13 with SMTP id 13so1684840fxm.19
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 23:51:39 -0700 (PDT)
In-Reply-To: <AANLkTi=o8GYdLyY8EzfRno39O2kUSh3wSp9raZCUp_Zz@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 septembre 2010 =C3=A0 18:39 -0400, Chetan Loke a =C3=A9c=
rit :
> Hi Bhavesh,
>=20
> On Fri, Sep 3, 2010 at 5:05 PM, Bhavesh Davda <bhavesh@vmware.com> wr=
ote:
>=20
> >
> > I presume you're talking about the vmxnet3 vNIC here? What version =
of the VMware hypervisor are you observing this with? Could you share t=
he vmware.log (and potentially the vmkernel log) file from the VM where=
 you're seeing this?
> >
>=20
> Yes its vmxnet3 on esx 4.1. I've attached the vm-log file. Its easy t=
o
> reproduce - A simple 'rcvfrom' loop on a promiscuous interface.
>=20
>=20

Reproduce what exactly ?=20

I dont understand what the problem is, reading your description.

RPS is not automatically switched on, you have to configure it.

echo ffff >/sys/class/net/eth0/queues/rx-0/rps_cpus

Same for RFS if you prefer to use RFS

echo 16384 >/sys/class/net/eth0/queues/rx-0/rps_flow_cnt

If you receive a flood, your cpu stay in NAPI mode, and no hardware
interrupt is received while you process xxx.xxx packets per second.



