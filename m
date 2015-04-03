From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] tc: cls_bpf: make ingress and egress qdiscs
 consistent
Date: Sat, 04 Apr 2015 00:54:12 +0200
Message-ID: <551F1A14.7080205@iogearbox.net>
References: <1428095784-7091-1-git-send-email-ast@plumgrid.com> <551F0A1B.3000100@iogearbox.net> <551F0B96.2090403@plumgrid.com> <551F0FE2.8000502@iogearbox.net> <551F1177.7090902@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35556 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbDCWyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 18:54:19 -0400
In-Reply-To: <551F1177.7090902@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2015 12:17 AM, Alexei Starovoitov wrote:
...
> 1. there shouldn't be a choice at all for bpf. Because not pulling l2
> means it's bug.

Yep, correct. You would also loose context for a possible dissection,
at best you only have skb->protocol.

> 2. adding a flag means adding it to iproute2 with default off and making
> users forgetting it from time to time and have no way of knowing why
> their programs all of a sudden stopped working.
>
> classic falls under the same rules. It doesn't make sense at all to run
> a program on packet without L2 header. It's very odd both for classic
> and extended programs.

Yep.

> Two 'if' conditions in critical path is bogus argument, since these
> checks would be there in ingress as well. Same critical path.

Why bogus? There would be no such test on the normal egress path,
where this is irrelevant. I wasn't talking about ingress here.

I see the point regarding the user option. So, why not adding a flag
to tcf_proto_ops a la `.flags = CLS_REQUIRES_L2` that gets propagated
to tcf_proto, and only ingress_enqueue() would need to test if the
classifier imposes that requirement, so it can push/pull.
