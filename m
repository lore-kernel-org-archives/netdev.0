From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next] tc: cls_bpf: make ingress and egress qdiscs
 consistent
Date: Sat, 04 Apr 2015 08:34:06 +0200
Message-ID: <551F85DE.3010804@iogearbox.net>
References: <1428095784-7091-1-git-send-email-ast@plumgrid.com> <551F0A1B.3000100@iogearbox.net> <551F0B96.2090403@plumgrid.com> <551F0FE2.8000502@iogearbox.net> <551F1177.7090902@plumgrid.com> <551F1A14.7080205@iogearbox.net> <551F1C9B.6070908@plumgrid.com> <551F1E13.8050508@plumgrid.com> <551F21A0.1030503@iogearbox.net> <551F26BE.1010607@iogearbox.net> <551F2CD4.2080502@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <551F2CD4.2080502-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/04/2015 02:14 AM, Alexei Starovoitov wrote:
> On 4/3/15 4:48 PM, Daniel Borkmann wrote:
>> On 04/04/2015 01:26 AM, Daniel Borkmann wrote:
>>> On 04/04/2015 01:11 AM, Alexei Starovoitov wrote:
>> ...
>>>> nope. will take it back.
>>>> that doesn't work, since this check cannot be done in ingress_enqueue(),
>>>> because it sees the pointer to first filter only, so both TCQ_F_INGRESS
>>>> flag and CLS_REQUIRES_L2 flag need to be checked inside
>>>
>>> So on a quick glance, we're calling into cls_bpf_classify() in
>>> tp->classify()
>>> (net/sched/cls_api.c +265), so all remaining filters in that list we're
>>> traversing in cls_bpf_classify() are all BPF filters, no?
>>
>> I see, you mean the classifier chain, not the chain of filters within
>> the cls_bpf classifier, ok.
>
> yes. the chain of classifiers can have different types, so we
> cannot check it once in ingress_enqueue().
> As you said we can refactor it later.

Too many indirections. :/ Yes, I'm fine with that, thanks.
