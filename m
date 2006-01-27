From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Fri, 27 Jan 2006 23:58:14 +0100
Message-ID: <43DAA586.5050609@cosmosbay.com>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190357.GE3651@localhost.localdomain> <43D9DFA1.9070802@cosmosbay.com> <20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org> <20060127224433.GB3565@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422647AbWA0W6S@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060127224433.GB3565@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai a =E9crit :
> On Fri, Jan 27, 2006 at 12:16:02PM -0800, Andrew Morton wrote:
>> Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>>> which can be assumed as not frequent. =20
>>> At sk_stream_mem_schedule(), read_sockets_allocated() is invoked on=
ly=20
>>> certain conditions, under memory pressure -- on a large CPU count m=
achine,=20
>>> you'd have large memory, and I don't think read_sockets_allocated w=
ould get=20
>>> called often.  It did not atleast on our 8cpu/16G box.  So this sho=
uld be OK=20
>>> I think.
>> That being said, the percpu_counters aren't a terribly successful co=
ncept
>> and probably do need a revisit due to the high inaccuracy at high CP=
U
>> counts.  It might be better to do some generic version of vm_acct_me=
mory()
>> instead.
>=20
> AFAICS vm_acct_memory is no better.  The deviation on large cpu count=
s is the=20
> same as percpu_counters -- (NR_CPUS * NR_CPUS * 2) ...

Ah... yes you are right, I read min(16, NR_CPUS*2)

I wonder if it is not a typo... I mean, I understand the more cpus you =
have,=20
the less updates on central atomic_t is desirable, but a quadratic offs=
et=20
seems too much...

Eric
