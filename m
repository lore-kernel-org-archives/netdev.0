From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: act: fix a bug in tcf_register_action()
Date: Wed, 15 Jan 2014 09:40:32 -0800
Message-ID: <CAM_iQpV_n-ptUJpU7gVcKSHFhXdS9caTQOJ4n6SKr7HGQv3S=Q@mail.gmail.com>
References: <1389739694-9251-1-git-send-email-xiyou.wangcong@gmail.com>
	<52D68069.1090804@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:51532 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbaAORkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 12:40:32 -0500
Received: by mail-oa0-f54.google.com with SMTP id o6so1586788oag.13
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 09:40:32 -0800 (PST)
In-Reply-To: <52D68069.1090804@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 4:34 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 01/14/14 17:48, Cong Wang wrote:
>>
>> In tcf_register_action() we check ->type and ->kind to see if there
>> is an existing action registered, but ipt action registers two
>> actions with same type but different kinds. This should be a valid
>> case, otherwise only xt can be registered.
>>
>
>
> We cant allow for conflicts by name or id - we want to catch them.
> So just introduce TCA_ACT_XT instead (ID 7)

Oh, I thought it is intentional to use the same type for xt and ipt.

>
> [
> Note: iptables used to be a constant moving API target
> and this is supposed to be the latest "backward compat mode".
> New kernel/iproute ==> We want to love "xt" more than "ipt".
> We infact want to eventually kill "ipt".
> but this preference is hard to achieve as you may have run into.
> I would be curious how you tested and run into this..
> ].
>

Just load the module, and you would see an error message. :)
