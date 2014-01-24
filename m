From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2 3/5] net_sched: act: move tcf_hashinfo_init()
 into tcf_register_action()
Date: Thu, 23 Jan 2014 16:52:00 -0800
Message-ID: <CAM_iQpV2zKF3vQGmsa0Fvcii2+tQTKmp=6a-odggbFnJK8snjQ@mail.gmail.com>
References: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
	<1390516525-8556-4-git-send-email-xiyou.wangcong@gmail.com>
	<20140123160859.147c6878@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:38138 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbaAXAwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:52:02 -0500
Received: by mail-ob0-f181.google.com with SMTP id va2so2932462obc.12
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 16:52:00 -0800 (PST)
In-Reply-To: <20140123160859.147c6878@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 4:08 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 23 Jan 2014 14:35:23 -0800
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>>
>>  struct tc_action {
>>       void                    *priv;
>> -     const struct tc_action_ops      *ops;
>> +     struct tc_action_ops    *ops;
>
> As much as possible all function tables should be constant.
> One of the rootkit tricks is to overwrite a function table entry
> at runtime. Granted tc action is a minor corner of the exposed
> universe, but this seems a step backwards when the only real
> gain is some refactoring/cleanup.

Yeah, then we can keep hinfo as a pointer in ops,
and allocate it dynamically.
