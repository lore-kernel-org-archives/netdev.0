From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH v2 net-next 1/2] bpf: allow extended BPF programs access
 skb fields
Date: Sun, 15 Mar 2015 00:51:37 +0100
Message-ID: <5504C989.8000800@iogearbox.net>
References: <1426273064-4837-1-git-send-email-ast@plumgrid.com> <1426273064-4837-2-git-send-email-ast@plumgrid.com> <550392F7.9040308@iogearbox.net> <550397B0.5070409@iogearbox.net> <5503981C.6000801@plumgrid.com> <55039A0D.20000@iogearbox.net> <55039C9D.6010602@plumgrid.com> <5503C03F.8020903@plumgrid.com> <550400D8.5060407@iogearbox.net> <550459E4.1050808@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <550459E4.1050808-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/14/2015 04:55 PM, Alexei Starovoitov wrote:
...
> so from there I saw two options: either copy paste all
> build_bug_on and have the same *insn=... and build_bug_on in
> two places or consolidate them in single helper function.
> Obviously single helper function is a preferred method.
> I'm not sure what are you still arguing about.

I'm repeating myself here, but fair enough. To me the v1
code in sk_filter_convert_ctx_access() was more sound. So
taking out the ifindex issue, that's 4 BUILD_BUG_ON()s in
addition.

I actually think the current filter code is in a reasonable
shape. convert_bpf_extensions() is full of BPF to eBPF
conversions, so going over convert_bpf_extensions() some of
them would now use convert_skb_access(), some other ``skb
accesses''use macros directly in place, the reading-flow of
this code now is inconsistent to me and it would have been
more sound if that's just left as is in convert_bpf_extensions().

I'm all for consolidating code, don't get me wrong, but I
think this exception would be better for above sake. That's
all I'm trying to say. I understand you're of exact opposite
opinion, so I guess it's pointless for me to comment any
further on this.

Thanks,
Daniel
