From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Wed, 26 Aug 2015 17:14:54 -0700
Message-ID: <CAM_iQpUwHSDnE=C8OMGgUOCwSZo2Cgi=0Dh6GRvmX8BEEGN_Uw@mail.gmail.com>
References: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
	<1440628887-3504-5-git-send-email-xiyou.wangcong@gmail.com>
	<20150826170802.27eff88c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34728 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbbH0AO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 20:14:56 -0400
Received: by oiex83 with SMTP id x83so2164845oie.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 17:14:54 -0700 (PDT)
In-Reply-To: <20150826170802.27eff88c@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 5:08 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 26 Aug 2015 15:41:26 -0700
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> Currently there is no check for if a qdisc is appropriate
>> to be used as the default qdisc. This causes we get no
>> error even we set the default qdisc to an inappropriate one
>> but an error will be shown up later. This is not good.
>>
>> Also, for qdisc's like HTB, kernel will just crash when
>> we use it as default qdisc, because some data structures are
>> not even initialized yet before checking opt == NULL, the cleanup
>> doing ->reset() or ->destroy() on them will just crash.
>
> Why not fix the buggy one's instead?

They are not exactly buggy, since they are fine in other ->init() calling
cases.

As in the first paragraph you quoted from me, it is more like
a usability issue, for example ingress qdisc can be set as default
without any error at any time.
