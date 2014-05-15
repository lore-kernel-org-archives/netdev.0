From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] rtnetlink: wait for unregistering devices in rtnl_link_unregister()
Date: Thu, 15 May 2014 11:43:26 -0700
Message-ID: <CAM_iQpVu+X7tM43QD23BpE9bNemVFcPznOmTFQb_pQ2gA=c9Qg@mail.gmail.com>
References: <1399932680-31479-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140515.143242.2060472577881743700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:34422 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938AbaEOSn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:43:27 -0400
Received: by mail-ob0-f174.google.com with SMTP id uz6so1736066obc.5
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 11:43:27 -0700 (PDT)
In-Reply-To: <20140515.143242.2060472577881743700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 11:32 AM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Mon, 12 May 2014 15:11:20 -0700
>
>> +static void rtnl_lock_unregistering_all(void)
>
> This is just:
>
>         rtnl_lock_unregistering(&net_namespace_list);
>
> There is no need to reimplement the entire thing.

This is exactly what I did in v0 (never sent out) locally,
I spent few hours to debug the problem. The problem
is net_namespace_list links netns by net->list,
while rtnl_lock_unregistering() uses net->exit_list.
Thus I used an ugly macro in v1.

There seems no other choice than  between
an ugly macro and duplicated code.
