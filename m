From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read()
 that get the selected hardware PMU conuter
Date: Wed, 5 Aug 2015 10:09:22 +0800
Message-ID: <55C17052.80803@huawei.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com> <1438678696-88289-4-git-send-email-xiakaixu@huawei.com> <55C0FC83.10504@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <acme@kernel.org>, <mingo@redhat.com>,
	<a.p.zijlstra@chello.nl>, <masami.hiramatsu.pt@hitachi.com>,
	<jolsa@kernel.org>, <daniel@iogearbox.net>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C0FC83.10504@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2015/8/5 1:55, Alexei Starovoitov =E5=86=99=E9=81=93:
> On 8/4/15 1:58 AM, Kaixu Xia wrote:
>> +static int check_func_limit(struct bpf_map **mapp, int func_id)
>=20
> how about 'check_map_func_compatibility' or 'check_map_func_affinity'=
 ?
>=20
>> +{
>> +    struct bpf_map *map =3D *mapp;
>=20
> why pass pointer to a pointer? single pointer would be be fine.
>=20
>> +    bool bool_map, bool_func;
>> +    int i;
>> +
>> +    if (!map)
>> +        return 0;
>> +
>> +    for (i =3D 0; i <=3D ARRAY_SIZE(func_limit); i++) {
>> +        bool_map =3D (map->map_type =3D=3D func_limit[i].map_type);
>> +        bool_func =3D (func_id =3D=3D func_limit[i].func_id);
>> +        /* only when map & func pair match it can continue.
>> +         * don't allow any other map type to be passed into
>> +         * the special func;
>> +         */
>> +        if (bool_map !=3D bool_func)
>> +            return -EINVAL;
>> +    }
>=20
> nice simplification!
>=20
> the rest of the changes look good.
> please respin your next set against net-next.

Thanks for your review! I will follow them in the next set.
>=20
>=20
> .
>=20
