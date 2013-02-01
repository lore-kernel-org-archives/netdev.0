From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net-next 3/4] netns: bridge: allow unprivileged users
 add/delete mdb entry
Date: Fri, 01 Feb 2013 11:59:03 +0800
Message-ID: <510B3D87.6050908@cn.fujitsu.com>
References: <1359685860-29636-1-git-send-email-gaofeng@cn.fujitsu.com> <1359685860-29636-3-git-send-email-gaofeng@cn.fujitsu.com> <20130201034629.GE8400@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, amwang@redhat.com, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, ebiederm@xmission.com,
	pablo@netfilter.org
To: Matt Helsley <matthltc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:29124 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753156Ab3BAD63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 22:58:29 -0500
In-Reply-To: <20130201034629.GE8400@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/02/01 11:46, Matt Helsley wrote:
> On Fri, Feb 01, 2013 at 10:30:59AM +0800, Gao feng wrote:
>> since the mdb table is belong to bridge device,and the
>> bridge device can only be seen in one netns.
>> So it's safe to allow unprivileged user which is the
>> creator of userns and netns to modify the mdb table.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/bridge/br_mdb.c | 3 ---
>>  1 file changed, 3 deletions(-)
>>
>> diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
>> index acc9f4c..38991e0 100644
>> --- a/net/bridge/br_mdb.c
>> +++ b/net/bridge/br_mdb.c
>> @@ -272,9 +272,6 @@ static int br_mdb_parse(struct sk_buff *skb, struct nlmsghdr *nlh,
>>  	struct net_device *dev;
>>  	int err;
>>
>> -	if (!capable(CAP_NET_ADMIN))
>> -		return -EPERM;
>> -
> 
> I'm wondering why this doesn't follow the:
> 
> ...
> - if (!capable(CAP_NET_ADMIN))
> + if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> 
> pattern like the rest of the changes you provided. Perhaps I'm
> neglecting something but it looks wrong to remove the CAP_NET_ADMIN
> check entirely.
> 

rtnetlink_rcv_msg has done this job,in commit dfc47ef8639facd77210e74be831943c2fdd9c74
Eric change capable to ns_capable in rtnetlink_rcv_msg and Push capable(CAP_NET_ADMIN)
into the rtnl methods.So we only need to do is remove this capable in br_mdb_parse.

Thanks!
