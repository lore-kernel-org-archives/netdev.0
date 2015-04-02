From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] tc: bpf: add checksum helpers
Date: Thu, 02 Apr 2015 09:34:59 -0700
Message-ID: <551D6FB3.7090304@plumgrid.com>
References: <1427933533-14394-1-git-send-email-ast@plumgrid.com> <551D599F.30408@iogearbox.net> <20150402151530.GD2613@nanopsycho.orion> <551D5E69.4050704@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <551D5E69.4050704-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/2/2015 8:21 AM, Daniel Borkmann wrote:
> On 04/02/2015 05:15 PM, Jiri Pirko wrote:
>> Thu, Apr 02, 2015 at 05:00:47PM CEST, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org wrote:
>>> On 04/02/2015 02:12 AM, Alexei Starovoitov wrote:
>>>> Commit 608cd71a9c7c ("tc: bpf: generalize pedit action") has added the
>>>> possibility to mangle packet data to BPF programs in the tc pipeline.
>>>> This patch adds two helpers bpf_l3_csum_replace() and
>>>> bpf_l4_csum_replace()
>>>> for fixing up the protocol checksums after the packet mangling.
>>>>
>>>> It also adds 'flags' argument to bpf_skb_store_bytes() helper to avoid
>>>> unnecessary checksum recomputations when BPF programs adjusting l3/l4
>>>> checksums and documents all three helpers in uapi header.
>>>>
>>>> Moreover, a sample program is added to show how BPF programs can
>>>> make use
>>>> of the mangle and csum helpers.
>>>>
>>>> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>>>
>>> I think in future we need to find a better place for these helpers,
>>> as they are for cls_bpf and act_bpf.
>>
>> Yeah, makes sense to now have it in net/core/filter.c. How about to
>> create net/bpf dir for these?
>
> I was thinking somewhere under net/sched/, f.e. net/sched/bpf.c
> as probably kernel/bpf/ would end up in too much ifdef pasta. :/

I would prefer to keep mangle and csum helpers in net/core/filter.c for
now, since it's not clear what networking subsystems beyond TC would
want to use them in the future. Otherwise we'll keep moving them back
and forth.
