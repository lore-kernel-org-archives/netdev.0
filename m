From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 2/4] net: Percpufy frequently used variables -- struct
 proto.memory_allocated
Date: Fri, 27 Jan 2006 10:01:15 +0100
Message-ID: <43D9E15B.9000407@cosmosbay.com>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190212.GD3651@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932427AbWA0JBk@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060126190212.GD3651@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai a =E9crit :
> Change struct proto->memory_allocated to a batching per-CPU counter=20
> (percpu_counter) from an atomic_t.  A batching counter is better than=
 a=20
> plain per-CPU counter as this field is read often.
>=20
> Signed-off-by: Pravin B. Shelar <pravins@calsoftinc.com>
> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> Signed-off-by: Shai Fultheim <shai@scalex86.org>
>=20

Hello Ravikiran

I like this patch, but I'm not sure current percpu_counter fits the nee=
ds.

The percpu_counter_read() can return a value that is off by +-
=46BC_BATCH*NR_CPUS, ie 2*(NR_CPUS^2) or 4*(NR_CPUS^2)

if NR_CPUS =3D 128, the 'error' from percpu_counter_read() is +- 32768

Is it acceptable ?

Thank you
Eric
