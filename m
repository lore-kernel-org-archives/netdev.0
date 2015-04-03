From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next] tc: cls_bpf: make ingress and egress qdiscs
 consistent
Date: Sat, 04 Apr 2015 01:26:24 +0200
Message-ID: <551F21A0.1030503@iogearbox.net>
References: <1428095784-7091-1-git-send-email-ast@plumgrid.com> <551F0A1B.3000100@iogearbox.net> <551F0B96.2090403@plumgrid.com> <551F0FE2.8000502@iogearbox.net> <551F1177.7090902@plumgrid.com> <551F1A14.7080205@iogearbox.net> <551F1C9B.6070908@plumgrid.com> <551F1E13.8050508@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <551F1E13.8050508-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/04/2015 01:11 AM, Alexei Starovoitov wrote:
> On 4/3/15 4:04 PM, Alexei Starovoitov wrote:
>> On 4/3/15 3:54 PM, Daniel Borkmann wrote:
...
>>> I see the point regarding the user option. So, why not adding a flag
>>> to tcf_proto_ops a la `.flags = CLS_REQUIRES_L2` that gets propagated
>>> to tcf_proto, and only ingress_enqueue() would need to test if the
>>> classifier imposes that requirement, so it can push/pull.
>>
>> ok. that sounds better, but neither tcf_proto nor tcf_proto_ops have
>> 'flags' field today... well, I guess it's time to add flags there.

I don't think it would be a big problem.

>> Probably add 'flags' to tcf_proto_ops only and do fl->ops->flags in
>> ingress_enqueue()?

Something along that line, yeah.

>> Will respin.
>
> nope. will take it back.
> that doesn't work, since this check cannot be done in ingress_enqueue(),
> because it sees the pointer to first filter only, so both TCQ_F_INGRESS
> flag and CLS_REQUIRES_L2 flag need to be checked inside

So on a quick glance, we're calling into cls_bpf_classify() in tp->classify()
(net/sched/cls_api.c +265), so all remaining filters in that list we're
traversing in cls_bpf_classify() are all BPF filters, no?

Have to grab some sleep for now, will be on travel tomorrow. Anyway, worst
case it could still be refactored later.
