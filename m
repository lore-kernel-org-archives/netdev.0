From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: add network namespace support for tc
 actions
Date: Mon, 22 Feb 2016 08:42:43 -0500
Message-ID: <56CB1053.8020102@mojatatu.com>
References: <1455928994-9726-1-git-send-email-xiyou.wangcong@gmail.com>
 <56C8B21E.7070307@iogearbox.net>
 <CAM_iQpWzVoy7eYdf2Yxz2qfoAO5-pDZioACyu7Hws6u7vvP1Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37772 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695AbcBVNmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 08:42:45 -0500
Received: by mail-ig0-f176.google.com with SMTP id 5so81726166igt.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 05:42:45 -0800 (PST)
In-Reply-To: <CAM_iQpWzVoy7eYdf2Yxz2qfoAO5-pDZioACyu7Hws6u7vvP1Yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-20 07:46 PM, Cong Wang wrote:
> On Sat, Feb 20, 2016 at 10:36 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>
>> Do you see a way to reduce the code duplication needed across all
>> the action modules? I.e. that each of them now needs to register
>> a new per netns subsystem, etc. In other words, is there a way the
>> action API could be reworked to handle most of this in the tc core
>> framework instead?
>
> I definitely agree.
>

Same here.


> Initially I made a wrapper macro for the per netns API for each tc
> action, but it didn't work as I thought, mostly due to the per net ops and
> net_id stuffs.
>
> So it is not as easy as it appears, it needs more work. At least the
> current code is more readable than using any macro. We can always
> refactor the API in the future, and as I mentioned in the changelog that
> is in my plan.
>
> Or do you have any quick and easy way to reduce the code?
>

I did a quick look and i am struggling with it. The patch seems largish
The issue is that we need to do this per kernel module so the code
churn maybe unavoidable; hinfo stored in act_ops complicates things.
Having said that:  All the pernet operations in your
code seem to be generic, other than to accomodate for module specific
act_ops. Is it possible to make generic pernet operations? This way
you could do things at tcf_register_action() for all actions.
The challenge seems to be in the xxx_net_id which appears(sorry didnt
look closely at the namespace code) to need to be unique id per module
and per namespace instance - otherwise i would suggest for xxx_net_id
to be part of act_ops. Could we not have an #ifdef in the namespace
core like the netfilter code does and have one level of indirection
for everything but the namespace 0?

cheers,
jamal
