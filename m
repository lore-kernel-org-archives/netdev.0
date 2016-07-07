From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] ipv6: Fix soft lockup for ipv6 network notifier.
Date: Thu, 7 Jul 2016 09:42:27 +0800
Message-ID: <577DB383.30202@huawei.com>
References: <57761E04.8030202@huawei.com>
 <1467359847.11238.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <5776258F.6080008@huawei.com>
 <1467361396.11238.35.camel@edumazet-glaptop3.roam.corp.google.com>
 <577CBE0E.1050809@huawei.com>
 <1467794644.1273.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <luto@kernel.org>, <mingo@kernel.org>,
	<linux-kernel@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467794644.1273.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/7/6 16:44, Eric Dumazet wrote:
> On Wed, 2016-07-06 at 16:15 +0800, Ding Tianhong wrote:
>> Hi Eric=EF=BC=9A
>>
>> I had found out that the patch aaf92f(netfilter: conntrack: resched =
in
>> nf_ct_iterate_cleanup) solve the problem,=20
>> this patch add cond_sched() in the nf_ct_iterate_cleanup() which wil=
l
>> be called in the net notifier chain every time,
>> and I revert this patch at kernel 4.7-rc4 , it will panic for soft
>> lockup, so I am not sure whether our patch is need,
>> it looks like if I disable the CONFIG for netfilter that would
>> register the nf_ct_iterate_cleanup as notifier, the problem still be
>> exist.
>=20
> Well, I do not have conntrack on my kernels, and I can not reproduce =
the
> issue.
>=20
> So I am guessing other patches also solved a scalability issue, betwe=
en
> 4.1 and 4.7
>=20
> I am aware of something that David did for IPv4, but this might help =
as
> well for IPv6.
>=20
> commit fbd40ea0180a2d328c5adc61414dc8bab9335ce2
> ipv4: Don't do expensive useless work during inetdev destroy.
>    =20

Hi Eric=EF=BC=9A

I check this patch:
[root@localhost linux]# git name-rev fbd40ea0180a2d328c5adc61414dc8bab9=
335ce2
fbd40ea0180a2d328c5adc61414dc8bab9335ce2 tags/v4.6-rc1~91^2~63

So the kernel4.7-RC4 already has this patch, but it have no effort if I=
 revert the commit  aaf92f(netfilter: conntrack: resched in
nf_ct_iterate_cleanup), So I don't think David's patch could fix this p=
roblem.

Thanks
Ding

>=20
>=20
>=20
>=20
