From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: fix mirrored packets checksum
Date: Thu, 30 Jun 2016 16:41:17 -0700
Message-ID: <CAM_iQpXd7-rx_XzoZ=8gVekLD0YRLkmr0kgud3WoXnjEvCOLZw@mail.gmail.com>
References: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com>
 <57757823.4090000@iogearbox.net> <CAM_iQpXtOr+AD2_q1E_dZm8MmLFAhdqPb6-_3ChgCr38gKi0yg@mail.gmail.com>
 <5775A710.9010105@iogearbox.net> <CAM_iQpVOVKyyGLqvSzB9L1Dugo_zXdrc0Qymy_gBVNMTPm-sHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <tom@herbertland.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34564 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbcF3Xlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:41:52 -0400
Received: by mail-qk0-f194.google.com with SMTP id j2so20125083qkf.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 16:41:37 -0700 (PDT)
In-Reply-To: <CAM_iQpVOVKyyGLqvSzB9L1Dugo_zXdrc0Qymy_gBVNMTPm-sHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 4:26 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Jun 30, 2016 at 4:11 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 07/01/2016 12:42 AM, Cong Wang wrote:
>>>
>>> On Thu, Jun 30, 2016 at 12:50 PM, Daniel Borkmann <daniel@iogearbox.net>
>>> wrote:
>>>>
>>>>
>>>> Maybe makes sense to move skb_push_rcsum() but /also/ skb_pull_rcsum()
>>>> to the header then? Both seem similarly small at least (could be split
>>>> f.e into two patches then, first for the move, second for the actual
>>>> fix).
>>>
>>>
>>> No objection from me. Please feel free to send a patch. ;)
>>
>>
>> Shrug, I actually meant this as feedback to your patch, since you move that
>> helper and not as a note to myself. ;)
>
> Interesting, my patch only moves what it needs, why does it need
> to do more?

In case you miss the context:
http://marc.info/?l=linux-netdev&m=146730654005424&w=2

This patch should be backported to stable too, which is another
reason why we should keep it as small as possible.

Here, at Twitter, we already backported it to 4.1 kernel for testing.

(The reason why I don't have a Fixes: tag is that I don't identify an
offending commit to blame yet.)
