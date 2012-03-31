From: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Subject: =?UTF-8?Q?=E7=AD=94=E5=A4=8D:_=E7=AD=94=E5=A4=8D:_=E7=AD=94=E5=A4=8D:_=5BP?=
	=?UTF-8?Q?ATCH=5D_set_fake=5Frtable's_dst_to_N?=
	=?UTF-8?Q?ULL_to_avoid_kernel_Oops.?=
Date: Sat, 31 Mar 2012 09:26:50 +0800
Message-ID: <004d01cd0edd$593f3bd0$0bbdb370$%huangpeng@huawei.com>
References: <002501cd0d74$317fd100$947f7300$%huangpeng@huawei.com>
 <1333002975.2325.82.camel@edumazet-glaptop>
 <002601cd0d76$c4987440$4dc95cc0$%huangpeng@huawei.com>
 <1333011120.2325.354.camel@edumazet-glaptop>
 <004501cd0d8f$c4e133b0$4ea39b10$%huangpeng@huawei.com>
 <1333020682.2325.517.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, harry.majun@huawei.com,
	zhoukang7@huawei.com, 'netdev' <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1333020682.2325.517.camel@edumazet-glaptop>
Content-language: zh-cn
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > >Check net/bridge/br_netfilter.c and commits e688a6048076 (net: introduce
> > >DST_NOPEER dst flag )  4adf0af6818f3ea5 (bridge: send correct MTU value
> > >in PMTU (revised))

Hi, Eric

I confirmed the patch contents again.
For our case, NF_INET_PRE_ROUTING is involved, not NF_BR_LOCAL_IN. 
It seems pre-routing is not included in the patch you mentioned.
BTW, our pkts are all ipv6 DHCP pkts(with MAC 33 33 00 01 00 02).

We verified the patch bellow, and this works fine, no WARN_ON happened. 

--------------------------------
Peter Huang(peng)

> On Thu, 2012-03-29 at 17:38 +0800, Peter Huang (Peng) wrote:
> > Thks for your mail.
> >
> > >Check net/bridge/br_netfilter.c and commits e688a6048076 (net: introduce
> > >DST_NOPEER dst flag )  4adf0af6818f3ea5 (bridge: send correct MTU value
> > >in PMTU (revised))
> >
> > This patch already included in kernel-3.3, but for our case, virtual tap device's delayed
> > Deletion will also cause kernel oops even in kernel3.3.
> 
> I was suggesting you take a look at the commit content ;)
> 
> Then you can see the code in br_nf_local_in(), a bit cleaner than yours.
> 
