From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Thu, 24 Jul 2008 00:34:24 +0200
Message-ID: <4887B1F0.3000407@trash.net>
References: <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com> <20080723150536.ded38b22.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ranjit Manomohan <ranjitm@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com, menage@google.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47862 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720AbYGWWee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 18:34:34 -0400
In-Reply-To: <20080723150536.ded38b22.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 22 Jul 2008 10:44:18 -0700 (PDT)
> Ranjit Manomohan <ranjitm@google.com> wrote:
> 
>> @@ -359,7 +370,12 @@ static int flow_classify(struct sk_buff *skb, struct tcf_proto *tp,
>>   			classid %= f->divisor;
>>
>>   		res->class   = 0;
>> -		res->classid = TC_H_MAKE(f->baseclass, f->baseclass + classid);
>> +
>> +		if (key == FLOW_KEY_CGROUP_CLASSID)
>> +			res->classid = TC_H_MAKE(f->baseclass, classid);
>> +		else
>> +			res->classid = TC_H_MAKE(f->baseclass,
>> +						 f->baseclass + classid);
> 
> This causes a warning:
> 
> net/sched/cls_flow.c: In function 'flow_classify':
> net/sched/cls_flow.c:344: warning: 'key' may be used uninitialized in this function
> 
> that warning is a non-issue if we happen to know that f->nkeys can
> never be zero.  I don't know if that is guaranteed at this code site?

It is by the flow_change() function, but special casing the
CGROUP_CLASSID is not acceptable anyway. There should be no
need for that, a simple linear mapping to classids is done
by default in mapping mode, the sk_cgroup_classid simply
shouldn't include qdisc IDs.
