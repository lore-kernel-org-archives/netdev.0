From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] tc: cls_bpf: make ingress and egress qdiscs
 consistent
Date: Fri, 03 Apr 2015 14:52:22 -0700
Message-ID: <551F0B96.2090403@plumgrid.com>
References: <1428095784-7091-1-git-send-email-ast@plumgrid.com> <551F0A1B.3000100@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <551F0A1B.3000100-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/3/15 2:46 PM, Daniel Borkmann wrote:
> On 04/03/2015 11:16 PM, Alexei Starovoitov wrote:
>> BPF programs attached to ingress and egress qdiscs see inconsistent
>> skb->data.
>> For ingress L2 header is already pulled, whereas for egress it's present.
>> That makes writing programs more difficult.
>> Make them consistent by pushing L2 before running the programs and
>> pulling
>> it back afterwards.
>> Similar approach is taken by skb_defer_rx_timestamp() which does
>> push/pull
>> before calling ptp_classify_raw()->BPF_PROG_RUN().
>>
>> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>
> Thanks for looking into this. This ends up going via ingress_enqueue(),

yes.

> right? Maybe it would be better to add a new netlink attribute for
> ingress qdisc there that sets a flag in ingress_qdisc_data to pull the
> header space before calling tc_classify() and restore it later on?
> So, it would be configurable from tc. Would that work?

you mean a flag that will affect all classifiers? I'm not sure other
classifiers care. Noone complained for years. I think it would be
overdesign. Here the fix is trivial, which is my preference.
