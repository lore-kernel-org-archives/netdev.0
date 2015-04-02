From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] tc: bpf: add checksum helpers
Date: Thu, 2 Apr 2015 19:46:03 +0200
Message-ID: <20150402174603.GE2613@nanopsycho.orion>
References: <1427933533-14394-1-git-send-email-ast@plumgrid.com>
 <551D599F.30408@iogearbox.net>
 <20150402151530.GD2613@nanopsycho.orion>
 <551D5E69.4050704@iogearbox.net>
 <551D6FB3.7090304@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35843 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbbDBRqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 13:46:06 -0400
Received: by wizk4 with SMTP id k4so23046159wiz.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 10:46:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <551D6FB3.7090304@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 02, 2015 at 06:34:59PM CEST, ast@plumgrid.com wrote:
>On 4/2/2015 8:21 AM, Daniel Borkmann wrote:
>>On 04/02/2015 05:15 PM, Jiri Pirko wrote:
>>>Thu, Apr 02, 2015 at 05:00:47PM CEST, daniel@iogearbox.net wrote:
>>>>On 04/02/2015 02:12 AM, Alexei Starovoitov wrote:
>>>>>Commit 608cd71a9c7c ("tc: bpf: generalize pedit action") has added the
>>>>>possibility to mangle packet data to BPF programs in the tc pipeline.
>>>>>This patch adds two helpers bpf_l3_csum_replace() and
>>>>>bpf_l4_csum_replace()
>>>>>for fixing up the protocol checksums after the packet mangling.
>>>>>
>>>>>It also adds 'flags' argument to bpf_skb_store_bytes() helper to avoid
>>>>>unnecessary checksum recomputations when BPF programs adjusting l3/l4
>>>>>checksums and documents all three helpers in uapi header.
>>>>>
>>>>>Moreover, a sample program is added to show how BPF programs can
>>>>>make use
>>>>>of the mangle and csum helpers.
>>>>>
>>>>>Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>>>
>>>>I think in future we need to find a better place for these helpers,
>>>>as they are for cls_bpf and act_bpf.
>>>
>>>Yeah, makes sense to now have it in net/core/filter.c. How about to
>>>create net/bpf dir for these?
>>
>>I was thinking somewhere under net/sched/, f.e. net/sched/bpf.c
>>as probably kernel/bpf/ would end up in too much ifdef pasta. :/
>
>I would prefer to keep mangle and csum helpers in net/core/filter.c for
>now, since it's not clear what networking subsystems beyond TC would
>want to use them in the future. Otherwise we'll keep moving them back
>and forth.

Well, therefore I suggested net/bpf/ dir as a place to store
net-subsystem specific bpf stuff.

>
