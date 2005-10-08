From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Is this skb recycle buffer helpful to improve Linux network stack
 performance?
Date: Sun, 09 Oct 2005 00:22:24 +0200
Message-ID: <434846A0.5080802@cosmosbay.com>
References: <BAY108-DAV4CDAEF052852412160A0893870@phx.gbl> <43483E57.1040205@cosmosbay.com> <BAY108-DAV140650CDA8608152927C4E93870@phx.gbl> <434843B5.3020306@cosmosbay.com> <BAY108-DAV4008FD962D8FEC0497CC193870@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932175AbVJHWW2@vger.kernel.org>
To: LeoY <multisyncfe991@hotmail.com>
In-Reply-To: <BAY108-DAV4008FD962D8FEC0497CC193870@phx.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LeoY a =E9crit :
> Hi Eric,
>=20
> Thanks for your reply.
> 1. For the packet size, this idea is targeting some specific network=20
> card driver and we assume all the packet size will not exceed 2KB.
> 2. Currently only Uni-Processor is considered(Hyper-threading is also=
=20
> disabled), I will add spin lock part once it works on the UP.
>=20

1) Even on Uni-Processor, you still need to protect against IRQS

2) The big cost of kmalloc()/kfree() come from the=20
local_irq_save(flags)/local_irq_restore(flags)

Once you add them in your code, you will discover you gain nothing comp=
ared to=20
kmalloc()/kfree() that already use a 'ring buffer' : More over, the sla=
b=20
implementation is designed to have separate 'ring buffer' (one for each=
 cpu),=20
so it is probably better than a 'central ring buffer'

Eric
