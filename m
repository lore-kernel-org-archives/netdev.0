From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] rtnetlink: wait for unregistering devices in
 rtnl_link_unregister()
Date: Thu, 15 May 2014 14:50:43 -0400 (EDT)
Message-ID: <20140515.145043.2164782223537934866.davem@davemloft.net>
References: <1399932680-31479-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140515.143242.2060472577881743700.davem@davemloft.net>
	<CAM_iQpVu+X7tM43QD23BpE9bNemVFcPznOmTFQb_pQ2gA=c9Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	cwang@twopensource.com, ebiederm@xmission.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbaEOSup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:50:45 -0400
In-Reply-To: <CAM_iQpVu+X7tM43QD23BpE9bNemVFcPznOmTFQb_pQ2gA=c9Qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 15 May 2014 11:43:26 -0700

> On Thu, May 15, 2014 at 11:32 AM, David Miller <davem@davemloft.net> wrote:
>> From: Cong Wang <xiyou.wangcong@gmail.com>
>> Date: Mon, 12 May 2014 15:11:20 -0700
>>
>>> +static void rtnl_lock_unregistering_all(void)
>>
>> This is just:
>>
>>         rtnl_lock_unregistering(&net_namespace_list);
>>
>> There is no need to reimplement the entire thing.
> 
> This is exactly what I did in v0 (never sent out) locally,
> I spent few hours to debug the problem. The problem
> is net_namespace_list links netns by net->list,
> while rtnl_lock_unregistering() uses net->exit_list.
> Thus I used an ugly macro in v1.
> 
> There seems no other choice than  between
> an ugly macro and duplicated code.

Thanks for explaining (again), I'll look at this some more.
