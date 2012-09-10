From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 2/4] xfrm: invalidate dst on policy insertion/deletion
Date: Mon, 10 Sep 2012 16:56:16 +0200
Message-ID: <504DFF90.3010802@6wind.com>
References: <20120907.144828.97793990734588625.davem@davemloft.net> <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com> <1347283338-4249-3-git-send-email-nicolas.dichtel@6wind.com> <504DF77B.7070000@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39963 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab2IJO4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 10:56:20 -0400
Received: by eekc1 with SMTP id c1so1221632eek.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 07:56:19 -0700 (PDT)
In-Reply-To: <504DF77B.7070000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/09/2012 16:21, Vlad Yasevich a =E9crit :
> On 09/10/2012 09:22 AM, Nicolas Dichtel wrote:
>> When a policy is inserted or deleted, all dst should be recalculated=
=2E
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   net/xfrm/xfrm_policy.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
>> index 741a32a..67f456d 100644
>> --- a/net/xfrm/xfrm_policy.c
>> +++ b/net/xfrm/xfrm_policy.c
>> @@ -602,6 +602,7 @@ int xfrm_policy_insert(int dir, struct xfrm_poli=
cy
>> *policy, int excl)
>>       xfrm_pol_hold(policy);
>>       net->xfrm.policy_count[dir]++;
>>       atomic_inc(&flow_cache_genid);
>> +    rt_genid_bump(net);
>>       if (delpol)
>>           __xfrm_policy_unlink(delpol, dir);
>>       policy->index =3D delpol ? delpol->index : xfrm_gen_index(net,=
 dir);
>>
>
> What about security_load_policy() and security_set_bools(). They also=
 bumps the
> flow_cache_genid by way of selinux_xfrm_notify_policyload().
Right. I'm not familiar with this part, but it seems you're right, rt_g=
enid=20
should be bumped too.
