From: "zheng.li" <zheng.x.li@oracle.com>
Subject: Re: [PATCH] bonding: Inactive slaves should keep inactive flag's
 value to 1 in tlb and alb mode.
Date: Tue, 25 Mar 2014 16:36:39 +0800
Message-ID: <53314017.8040104@oracle.com>
References: <1395716407-31601-1-git-send-email-zheng.x.li@oracle.com> <5330FB34.4090005@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5330FB34.4090005@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2014=E5=B9=B403=E6=9C=8825=E6=97=A5 11:42, Ding Tianhong =E5=86=
=99=E9=81=93:
> On 2014/3/25 11:00, Zheng Li wrote:
>> In bond mode tlb and alb, inactive slaves should keep inactive flag =
to
>> 1 to refuse to receive broadcast packets. Now, active slave send bro=
adcast packets
>> (for example ARP requests) which will arrive inactive slaves on same=
 host from switch,
>> but inactive slave's inactive flag is zero that cause bridge receive=
 the broadcast
>> packets to produce a wrong entry in forward table. Typical situation=
 is domu send some
>> ARP request which go out from dom0 bond's active slave, then the ARP=
 broadcast request
>> packets go back to inactive slave from switch, because the inactive =
slave's inactive
>> flag is zero, kernel will receive the packets and pass them to bridg=
e, that cause dom0's
>> bridge map domu's MAC address to port of bond, bridge should map dom=
u's MAC to port of vif.
>>
>> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>> ---
>>  drivers/net/bonding/bond_main.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index e5628fc..8761df6 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -3062,7 +3062,7 @@ static int bond_open(struct net_device *bond_d=
ev)
>>  				&& (slave !=3D bond->curr_active_slave)) {
>>  				bond_set_slave_inactive_flags(slave,
>>  							      BOND_SLAVE_NOTIFY_NOW);
>> -			} else {
>> +			} else if (!bond_is_lb(bond)) {
>>  				bond_set_slave_active_flags(slave,
>>  							    BOND_SLAVE_NOTIFY_NOW);
>>  			}
>>
> I think you did not fix the problem completely, the state monitor wil=
l change the status for the slaves
> and the inactive slave still could receive the broadcast.

Had tested, it can fix the issue, verified by our QA.
Default set slave of bond as inactive when add a slave to bond, when
link UP, just set one slave as current active slave and clear its
inactive flag, the inactive slave's inactive flag will keep the value o=
f 1.


>=20
> Regards
> Ding
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
