From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/1] igmp: call ip_mc_clear_src() only when we have
 no users of ip_mc_list
Date: Tue, 24 May 2011 13:28:25 -0400 (EDT)
Message-ID: <20110524.132825.968974982805294440.davem@davemloft.net>
References: <20110520162709.GA3497@darkmag.usersys.redhat.com>
	<OF8F2A5C61.8060D0CC-ON88257899.00610B06-88257899.006123E3@us.ibm.com>
	<20110524091505.GA21550@darkmag.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, jmorris@namei.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, mmarek@suse.cz,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: vfalico@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110524091505.GA21550@darkmag.usersys.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 24 May 2011 11:15:05 +0200

> In igmp_group_dropped() we call ip_mc_clear_src(), which resets the number
> of source filters per mulitcast. However, igmp_group_dropped() is also
> called on NETDEV_DOWN, NETDEV_PRE_TYPE_CHANGE and NETDEV_UNREGISTER, which
> means that the group might get added back on NETDEV_UP, NETDEV_REGISTER and
> NETDEV_POST_TYPE_CHANGE respectively, leaving us with broken source
> filters.
> 
> To fix that, we must clear the source filters only when there are no users
> in the ip_mc_list, i.e. in ip_mc_dec_group() and on device destroy.
> 
> Acked-by: David L Stevens <dlstevens@us.ibm.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied.
