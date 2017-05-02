From: Jens Axboe <axboe@kernel.dk>
Subject: Re: linux-next: build failure after merge of the block tree
Date: Mon, 1 May 2017 19:09:34 -0600
Message-ID: <5CC6C5A2-B648-45F4-ACD4-AB27CE9AF9BF@kernel.dk>
References: <20170418130229.04289bd6@canb.auug.org.au> <20170502110704.79bb7760@canb.auug.org.au>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Josef Bacik <josef@toxicpanda.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Linus <torvalds@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170502110704.79bb7760@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On May 1, 2017, at 7:07 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:=

>=20
> Hi all,
>=20
>> On Tue, 18 Apr 2017 13:02:29 +1000 Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
>>=20
>> After merging the block tree, today's linux-next build (powerpc
>> ppc64_defconfig) failed like this:
>>=20
>> drivers/block/nbd.c: In function 'nbd_genl_connect':
>> drivers/block/nbd.c:1662:10: error: too few arguments to function 'nla_pa=
rse_nested'
>>    ret =3D nla_parse_nested(socks, NBD_SOCK_MAX, attr,
>>          ^
>> In file included from include/net/rtnetlink.h:5:0,
>>                 from include/net/sch_generic.h:12,
>>                 from include/linux/filter.h:20,
>>                 from include/net/sock.h:64,
>>                 from drivers/block/nbd.c:32:
>> include/net/netlink.h:754:19: note: declared here
>> static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
>>                   ^
>> drivers/block/nbd.c: In function 'nbd_genl_reconfigure':
>> drivers/block/nbd.c:1818:10: error: too few arguments to function 'nla_pa=
rse_nested'
>>    ret =3D nla_parse_nested(socks, NBD_SOCK_MAX, attr,
>>          ^
>> In file included from include/net/rtnetlink.h:5:0,
>>                 from include/net/sch_generic.h:12,
>>                 from include/linux/filter.h:20,
>>                 from include/net/sock.h:64,
>>                 from drivers/block/nbd.c:32:
>> include/net/netlink.h:754:19: note: declared here
>> static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
>>                   ^
>>=20
>> Caused by commits
>>=20
>>  e46c7287b1c2 ("nbd: add a basic netlink interface")
>>  b7aa3d39385d ("nbd: add a reconfigure netlink command")
>>=20
>> interacting with commit
>>=20
>>  fceb6435e852 ("netlink: pass extended ACK struct to parsing functions")
>>=20
>> from the net-next tree.
>>=20
>> I have applied the following merge fix patch:
>>=20
>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>> Date: Tue, 18 Apr 2017 12:59:05 +1000
>> Subject: [PATCH] nbd: fix up for nla_parse_nested() API change
>>=20
>> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> ---
>> drivers/block/nbd.c | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
>> index b78f23ce2395..5049d19f3940 100644
>> --- a/drivers/block/nbd.c
>> +++ b/drivers/block/nbd.c
>> @@ -1660,7 +1660,7 @@ static int nbd_genl_connect(struct sk_buff *skb, st=
ruct genl_info *info)
>>                goto out;
>>            }
>>            ret =3D nla_parse_nested(socks, NBD_SOCK_MAX, attr,
>> -                           nbd_sock_policy);
>> +                           nbd_sock_policy, NULL);
>>            if (ret !=3D 0) {
>>                printk(KERN_ERR "nbd: error processing sock list\n");
>>                ret =3D -EINVAL;
>> @@ -1816,7 +1816,7 @@ static int nbd_genl_reconfigure(struct sk_buff *skb=
, struct genl_info *info)
>>                goto out;
>>            }
>>            ret =3D nla_parse_nested(socks, NBD_SOCK_MAX, attr,
>> -                           nbd_sock_policy);
>> +                           nbd_sock_policy, NULL);
>>            if (ret !=3D 0) {
>>                printk(KERN_ERR "nbd: error processing sock list\n");
>>                ret =3D -EINVAL;
>> --=20
>> 2.11.0
>=20
> So, this merge fix is now needed when the net-next tree is merged (as
> Linus has merged the block tree).

Indeed, I have warned Linus about it. Thanks Stephen.=20
