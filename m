From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next] bpf: allow BPF programs access 'protocol' and
 'vlan_tci' fields
Date: Tue, 17 Mar 2015 10:22:27 +0100
Message-ID: <5507F253.9000806@iogearbox.net>
References: <1426554362-29991-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426554362-29991-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/17/2015 02:06 AM, Alexei Starovoitov wrote:
> as a follow on to patch 70006af95515 ("bpf: allow eBPF access skb fields")
> this patch allows 'protocol' and 'vlan_tci' fields to be accessible
> from extended BPF programs.
>
> The usage of 'protocol', 'vlan_present' and 'vlan_tci' fields is the same as
> corresponding SKF_AD_PROTOCOL, SKF_AD_VLAN_TAG_PRESENT and SKF_AD_VLAN_TAG
> accesses in classic BPF.
>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>

Ok, code looks good to me.

> 1.
> I was thinking to drop ntohs() from 'protocol' field for extended BPF, since
> the programs could do:
> if (skb->protocol == htons(ETH_P_IP))
> which would have saved one or two cpu cycles.
> But having similar behavior between classic and extended seems to be better.

I'm thinking that skb->protocol == htons(ETH_P_IP) might actually
be more obvious, and, as you mentioned, the compiler can already
resolve the htons() during compile time instead of runtime, which
would be another plus.

Either behavior we should document later anyway.

The question to me here is, do we need to keep similar behavior?

After all, the way of programming both from a user perspective is
quite different (i.e. bpf_asm versus C/LLVM).

Similarly, I was wondering, if just exporting raw skb->vlan_tci is
already sufficient, and the user can e.g. write helpers to extract
bits himself from that protocol field?

> 2.
> 'vlan_tci' name is picked to match real sk_buff->vlan_tci field
> and matches tpacket's tp_vlan_tci field.
