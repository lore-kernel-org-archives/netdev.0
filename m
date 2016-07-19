From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 19 Jul 2016 17:03:40 +0200
Message-ID: <578E414C.1080501@iogearbox.net>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com> <20160718041933.GB36253@ast-mbp.thefacebook.com> <578C7C5C.2070804@mojatatu.com> <578CA4EB.7060703@iogearbox.net> <578CAA96.2090501@mojatatu.com> <578E2960.7080709@iogearbox.net> <578E3172.9020601@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35301 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbcGSPDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 11:03:46 -0400
In-Reply-To: <578E3172.9020601@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2016 03:56 PM, Jamal Hadi Salim wrote:
[...]
>> But apart from this,
>> neither pedit nor tcf_skbmod_run() here handle checksum complete, so you'll
>> potentially get false positives wrt csum corruption and drops as a result
>> when using either of the two.
>
> pedit maybe tricky. Any suggestions?
> On tcf_skbmod_run, mostly ignorance: while doing only ethernet updates;
> is it still needed to do the checksum complete?

Well, what Cong recently fixed with mirred was related to mac header ...

You probably need skb_postpull_rcsum(), skb_postpush_rcsum() pair.

Also, what about skb_try_make_writable()?
