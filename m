From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] Replace rwlock on xfrm_policy_afinfo with rcu
Date: Tue, 07 Aug 2012 22:55:31 -0700 (PDT)
Message-ID: <20120807.225531.618417929491214091.davem@davemloft.net>
References: <1344316904-2544-1-git-send-email-Priyanka.Jain@freescale.com>
	<20120807.162138.5000306557864030.davem@davemloft.net>
	<AC83832D6324604BB08FAE5A33553F1907A96EA6@039-SN2MPN1-012.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: B32167@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455Ab2HHFze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 01:55:34 -0400
In-Reply-To: <AC83832D6324604BB08FAE5A33553F1907A96EA6@039-SN2MPN1-012.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jain Priyanka-B32167 <B32167@freescale.com>
Date: Wed, 8 Aug 2012 04:53:42 +0000

> 
> 
> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, August 08, 2012 4:52 AM
> To: Jain Priyanka-B32167
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH][XFRM] Replace rwlock on xfrm_policy_afinfo with rcu
> 
> From: Priyanka Jain <Priyanka.Jain@freescale.com>
> Date: Tue, 7 Aug 2012 10:51:44 +0530
> 
>> xfrm_policy_afinfo is read mosly data structure.
>> Write on xfrm_policy_afinfo is done only at the time of configuration.
>> So rwlocks can be safely replaced with RCU.
>> 
>> RCUs usage optimizes the performance.
>> 
>> Signed-off-by: Priyanka Jain <Priyanka.Jain@freescale.com>
> 
> This patch doesn't apply to the net-next tree, please respin.
> [Priyanka]: I will send v2 after re-spinning against git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git.
> 
> Also:
> 
>> -			xfrm_policy_afinfo[afinfo->family] = NULL;
>> +			rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family],
>> +				NULL);
> 
> Indent that NULL argument properly, it must line up with the first column after the openning '(' on the previous line.
> [Priyanka]: NULL has been pushed to next line to confirm to 80 characters per line rule. If I indent NULL to previous line, it will break 80 characters per line rule.
> Please let me know your final say on this. I will make changes accordingly if required.

What in the world are you talking about?

The openning parenthesis of the rcu_assign_pointer() statement is not anywhere
close to the 80th column.

You're doing this:

		x(A,
	B);

and I want you to do this:

		x(A,
		  B);
