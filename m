From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Tue, 07 Apr 2015 21:48:57 -0700
Message-ID: <5524B339.1070403@plumgrid.com>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com>	<1428455025-5945-2-git-send-email-ast@plumgrid.com> <20150407.223549.335906307265617841.davem@davemloft.net> <55249EFA.5040405@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jiri@resnulli.us, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:36912 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbbDHEtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 00:49:00 -0400
Received: by igblo3 with SMTP id lo3so29606804igb.0
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 21:49:00 -0700 (PDT)
In-Reply-To: <55249EFA.5040405@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/7/15 8:22 PM, Alexei Starovoitov wrote:
> but it seems no one cares about using them with ingress, so I'll go back
> to cls_bpf specific skb_share_check and push.

that didn't work either :(
we cannot replace skb via skb_share_check() inside cls/act. We cannot do
it inside ingress_enqueue() either. It can only be done at handle_ing()
level. And it's quite ugly to change the signatures of the whole
qdisc->enqueue() call chain just for cls_bpf. May be introducing
bpf-only ingress qdisc to decouple the logic is not such a bad idea?
Then ing_filter() can special case it just like != noop_qdisc.
Or a flag for existing ingress qdisc? Will see how it looks.
