From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 19 Jul 2016 11:04:13 -0700
Message-ID: <CAM_iQpWX5HT_yF3guCbQLMo2GSVGA8BTcJ3_bucHrnBrMQbjqw@mail.gmail.com>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
 <20160718041933.GB36253@ast-mbp.thefacebook.com> <578C7C5C.2070804@mojatatu.com>
 <578CA4EB.7060703@iogearbox.net> <578CAA96.2090501@mojatatu.com>
 <578E2960.7080709@iogearbox.net> <578E3172.9020601@mojatatu.com> <578E414C.1080501@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34372 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbcGSSEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 14:04:33 -0400
Received: by mail-io0-f174.google.com with SMTP id q83so26272102iod.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:04:33 -0700 (PDT)
In-Reply-To: <578E414C.1080501@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 8:03 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 07/19/2016 03:56 PM, Jamal Hadi Salim wrote:
> [...]
>>>
>>> But apart from this,
>>> neither pedit nor tcf_skbmod_run() here handle checksum complete, so
>>> you'll
>>> potentially get false positives wrt csum corruption and drops as a result
>>> when using either of the two.
>>
>>
>> pedit maybe tricky. Any suggestions?
>> On tcf_skbmod_run, mostly ignorance: while doing only ethernet updates;
>> is it still needed to do the checksum complete?
>
>
> Well, what Cong recently fixed with mirred was related to mac header ...
>
> You probably need skb_postpull_rcsum(), skb_postpush_rcsum() pair.
>
> Also, what about skb_try_make_writable()?

I don't think so. 1) checksum is supposed to be done by csum action
rather than pedit (or skbmod if it matters), 2) csum action currently
already handles that correctly for both egress and ingress: 2a)
CHECKSUM_COMPLETE is meaningless on egress; 2b) it forces
CHECKSUM_COMPLETE to be CHECKSUM_NONE on ingress
and it is correctly respected.
