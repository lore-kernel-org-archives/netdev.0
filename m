From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] tc: cls_bpf: make ingress and egress qdiscs
 consistent
Date: Sat, 04 Apr 2015 01:48:14 +0200
Message-ID: <551F26BE.1010607@iogearbox.net>
References: <1428095784-7091-1-git-send-email-ast@plumgrid.com> <551F0A1B.3000100@iogearbox.net> <551F0B96.2090403@plumgrid.com> <551F0FE2.8000502@iogearbox.net> <551F1177.7090902@plumgrid.com> <551F1A14.7080205@iogearbox.net> <551F1C9B.6070908@plumgrid.com> <551F1E13.8050508@plumgrid.com> <551F21A0.1030503@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38858 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbbDCXsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 19:48:25 -0400
In-Reply-To: <551F21A0.1030503@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2015 01:26 AM, Daniel Borkmann wrote:
> On 04/04/2015 01:11 AM, Alexei Starovoitov wrote:
...
>> nope. will take it back.
>> that doesn't work, since this check cannot be done in ingress_enqueue(),
>> because it sees the pointer to first filter only, so both TCQ_F_INGRESS
>> flag and CLS_REQUIRES_L2 flag need to be checked inside
>
> So on a quick glance, we're calling into cls_bpf_classify() in tp->classify()
> (net/sched/cls_api.c +265), so all remaining filters in that list we're
> traversing in cls_bpf_classify() are all BPF filters, no?

I see, you mean the classifier chain, not the chain of filters within
the cls_bpf classifier, ok.

> Have to grab some sleep for now, will be on travel tomorrow. Anyway, worst
> case it could still be refactored later.
