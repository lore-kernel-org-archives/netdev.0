From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net 0/5] net_sched: tc action fixes and updates
Date: Wed, 10 Aug 2016 10:34:14 -0400
Message-ID: <a79fc4fd-69aa-0af6-bb2d-7729610f97e4@mojatatu.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36822 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936313AbcHJSpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:45:25 -0400
Received: by mail-pa0-f49.google.com with SMTP id pp5so18126532pac.3
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 11:44:39 -0700 (PDT)
In-Reply-To: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-08 04:46 PM, Cong Wang wrote:
> This patchset fixes several regressions caused by the previous
> code refactor. Thanks to Jamal for catching them!
>

Cong,

Good news: oops gone. I havent done more testing than I did
before; but looks good so far.

Bad news: You have introduced a performance regression which is
noticeable at high speed.

tcf_exts_exec() is the culprit - and conversion to from flexarray
to linked list in the fast problem to be specific.
The regression is problematic (and unacceptable). Two options:
a) You fix the regressions - which i think may require changing
what gets passed around an executed on as an array instead of a
list.
b) I am worried #a will take some work. So the second option is
to back out the patch since there are known stability options;
get regression issues resolved and then go back and submit.

cheers,
jamla
