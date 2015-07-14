From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Tue, 14 Jul 2015 08:46:27 -0700
Message-ID: <55A52ED3.8090003@plumgrid.com>
References: <1436573411-5021-1-git-send-email-ast@plumgrid.com>	<20150711.212917.1463596559900301434.davem@davemloft.net>	<55A415DE.8020806@plumgrid.com> <20150713.130438.1857789246357119116.davem@davemloft.net> <55A41CE9.8050907@plumgrid.com> <55A425C4.60301@iogearbox.net> <55A43B26.1010009@plumgrid.com> <55A4E479.8080101@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jhs@mojatatu.com,
	jiri@resnulli.us, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35289 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbGNPq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 11:46:28 -0400
Received: by pactm7 with SMTP id tm7so7640686pac.2
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 08:46:27 -0700 (PDT)
In-Reply-To: <55A4E479.8080101@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/14/15 3:29 AM, Daniel Borkmann wrote:
> One other thing that comes to mind, not sure if it's worth it though,
> would be to split the skb->tc_verd's TC_NCLS itself into TC_NCLS/TC_NACT,
> so that you can go into the classifier, but skip the action part.
>
> Since in tcf_action_exec(), we already test for that, you might be able
> to add this with no extra cost. pktgen would then need to tag its skb
> with TC_NACT, so that you'll always return with TC_ACT_OK. And if you
> really would want to test tc actions, then w/o pktgen bursting ...

imo it's even uglier. Majority of the actions are fine with shared skb,
so blank disable is no good at all.
The cost of 'unlikely(is_pktgen_shared_skb' is tiny, but fine,
we dug up the dirt enough.
I'm taking option 3 (do nothing) at this point.
