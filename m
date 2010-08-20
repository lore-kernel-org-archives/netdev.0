From: yao zhao <dragonlinux@gmail.com>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 13:54:11 -0400
Message-ID: <AANLkTin8SXBtnKsaWdb64h2UVCZ57zHFOoZUWbbz_7HM@mail.gmail.com>
References: <20100820133320.GA29311@verge.net.au>
	<AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
	<1282313150.2484.65.camel@edumazet-laptop>
	<AANLkTi=t7wDZO23Cim1LJ_Ot2FUe4bR+XG6H5uJfTuG+@mail.gmail.com>
	<1282314765.2484.104.camel@edumazet-laptop>
	<AANLkTikCd_xCWUN+dkb_BkOrkBGSPe4xkmAebtgEiufy@mail.gmail.com>
	<1282318337.2484.219.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Simon Horman <horms@verge.net.au>,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1282318337.2484.219.camel@edumazet-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 20, 2010 at 11:32 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le vendredi 20 ao=FBt 2010 =E0 11:04 -0400, yao zhao a =E9crit :
>
>> The code here is deleting a global from the list, am I right? I didn=
't
>> see any called case.
>> what are you going to do more? free it? write_unlock_bh should make =
the mb.
>
>
> If you dont wait _after_ delete from list and following actions
> (kfree() without a call_rcu(), or module unload, or whatever), a read=
er
> might access your data/code and crash the box.
>
> spin_unlock_bh() wont help you at all, since only writers are freezed=
 by
> the lock (since readers only hold rcu_lock)
>
> Documentation/RCU/whatisRCU.txt line 705
>
> Documentation/RCU/checklist.txt =A015)
>
>
>
>
I read the code again and that global is in a module then you are right=
=2E
If that global is not in a module then you don't need it at all, as in
that global only functions pointer or name... which never be changed.

yao
