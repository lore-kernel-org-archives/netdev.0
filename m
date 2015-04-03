From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] tc: cls_bpf: make ingress and egress qdiscs
 consistent
Date: Fri, 03 Apr 2015 16:04:59 -0700
Message-ID: <551F1C9B.6070908@plumgrid.com>
References: <1428095784-7091-1-git-send-email-ast@plumgrid.com> <551F0A1B.3000100@iogearbox.net> <551F0B96.2090403@plumgrid.com> <551F0FE2.8000502@iogearbox.net> <551F1177.7090902@plumgrid.com> <551F1A14.7080205@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <551F1A14.7080205-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/3/15 3:54 PM, Daniel Borkmann wrote:
> On 04/04/2015 12:17 AM, Alexei Starovoitov wrote:
> ...
>> 1. there shouldn't be a choice at all for bpf. Because not pulling l2
>> means it's bug.
>
> Yep, correct. You would also loose context for a possible dissection,
> at best you only have skb->protocol.
>
>> 2. adding a flag means adding it to iproute2 with default off and making
>> users forgetting it from time to time and have no way of knowing why
>> their programs all of a sudden stopped working.
>>
>> classic falls under the same rules. It doesn't make sense at all to run
>> a program on packet without L2 header. It's very odd both for classic
>> and extended programs.
>
> Yep.
>
>> Two 'if' conditions in critical path is bogus argument, since these
>> checks would be there in ingress as well. Same critical path.
>
> Why bogus? There would be no such test on the normal egress path,
> where this is irrelevant. I wasn't talking about ingress here.
>
> I see the point regarding the user option. So, why not adding a flag
> to tcf_proto_ops a la `.flags = CLS_REQUIRES_L2` that gets propagated
> to tcf_proto, and only ingress_enqueue() would need to test if the
> classifier imposes that requirement, so it can push/pull.

ok. that sounds better, but neither tcf_proto nor tcf_proto_ops have
'flags' field today... well, I guess it's time to add flags there.
Probably add 'flags' to tcf_proto_ops only and do fl->ops->flags in
ingress_enqueue()?

Will respin.
