From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Wed, 08 Apr 2015 14:31:27 +0200
Message-ID: <55251F9F.2050508@iogearbox.net>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com> <1428455025-5945-2-git-send-email-ast@plumgrid.com> <20150407.223549.335906307265617841.davem@davemloft.net> <55249EFA.5040405@plumgrid.com> <5524B339.1070403@plumgrid.com> <5524E878.7070803@iogearbox.net> <20150408090520.GA2057@nanopsycho.orion> <552508E8.5050203@iogearbox.net> <55250D92.6030702@iogearbox.net> <55251556.4040900@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tgraf@suug.ch
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60078 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbbDHMbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 08:31:35 -0400
In-Reply-To: <55251556.4040900@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 01:47 PM, Jamal Hadi Salim wrote:
> Should have read my emails backward. Refer to my other email

Ok, sure.

> So why are you not able to use the indicators of where in the stack
> you are in both actions and classifiers?
> bpf needs to adjust.

So aside from the ifb dev, the only guys caring about AT_INGRESS
and AT_EGRESS is netem and act_mirred. That means the tc's cls_u32
sample selectors a la ip, ip6, udp, tcp, icmp don't work on ingress
either, so in u32 speak you would need to do that by hand, but that
doesn't work as you don't have the Ethernet type context available.
Am I missing something? :)
