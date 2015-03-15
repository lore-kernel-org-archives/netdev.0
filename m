From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 1/2] bpf: allow extended BPF programs access
 skb fields
Date: Sat, 14 Mar 2015 19:02:57 -0700
Message-ID: <5504E851.7000302@plumgrid.com>
References: <1426273064-4837-1-git-send-email-ast@plumgrid.com> <1426273064-4837-2-git-send-email-ast@plumgrid.com> <550392F7.9040308@iogearbox.net> <550397B0.5070409@iogearbox.net> <5503981C.6000801@plumgrid.com> <55039A0D.20000@iogearbox.net> <55039C9D.6010602@plumgrid.com> <5503C03F.8020903@plumgrid.com> <550400D8.5060407@iogearbox.net> <550459E4.1050808@plumgrid.com> <5504C989.8000800@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5504C989.8000800@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/14/15 4:51 PM, Daniel Borkmann wrote:
> On 03/14/2015 04:55 PM, Alexei Starovoitov wrote:
> ...
>> so from there I saw two options: either copy paste all
>> build_bug_on and have the same *insn=... and build_bug_on in
>> two places or consolidate them in single helper function.
>> Obviously single helper function is a preferred method.
>> I'm not sure what are you still arguing about.
>
> I'm repeating myself here, but fair enough. To me the v1
> code in sk_filter_convert_ctx_access() was more sound. So
> taking out the ifindex issue, that's 4 BUILD_BUG_ON()s in
> addition.

correct. it's 4 build_bug_on to several lines of copy pasted code.
That copy-paste between two functions was already bugging me
when I posted v1, but back then I didn't see a way to create
a common helper.
Adding this 4 extra lines pushed it over my internal bar of
'acceptable' copied code :)
so in v2 I figured a way to create a helper.

> I actually think the current filter code is in a reasonable
> shape. convert_bpf_extensions() is full of BPF to eBPF
> conversions, so going over convert_bpf_extensions() some of
> them would now use convert_skb_access(), some other ``skb
> accesses''use macros directly in place, the reading-flow of
> this code now is inconsistent to me and it would have been
> more sound if that's just left as is in convert_bpf_extensions().

I still don't see this 'inconsistency'.
convert_bpf_extensions() has code to convert classic only accesses.
convert_skb_access() has code to convert both classic and extended.
sk_filter_convert_ctx_access() has code to convert extended only.

In this patch convert_skb_access() has to deal with 3 fields.
Later we may allow more field to be accessed by extended, so
more lines will simply move from convert_bpf_extensions() into
convert_skb_access(). So it will save us from copy-pasting in the
future.
