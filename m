From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 net-next 1/2] bpf: allow extended BPF programs access
 skb fields
Date: Sat, 14 Mar 2015 08:55:16 -0700
Message-ID: <550459E4.1050808@plumgrid.com>
References: <1426273064-4837-1-git-send-email-ast@plumgrid.com> <1426273064-4837-2-git-send-email-ast@plumgrid.com> <550392F7.9040308@iogearbox.net> <550397B0.5070409@iogearbox.net> <5503981C.6000801@plumgrid.com> <55039A0D.20000@iogearbox.net> <55039C9D.6010602@plumgrid.com> <5503C03F.8020903@plumgrid.com> <550400D8.5060407@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <550400D8.5060407-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/14/15 2:35 AM, Daniel Borkmann wrote:
> On 03/14/2015 05:59 AM, Alexei Starovoitov wrote:
>> also note that this case and twsk_build_assert are different.
>> twsk_build_assert has no other choice then to have one function
>> that covers logic in the whole file, whereas in this patch:
>> +               BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
>> +               *insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
>> +                                     offsetof(struct sk_buff, mark));
>>
>> the build_bug_on protect the line directly below.
>> Separating them just doesn't make sense at all.
>
> I also like the above approach better, I only suggested that as a
> possible alternative since you were saying earlier in this thread:
>
>    I thought about it, but didn't add it, since we already have them
>    in the same file several lines above this spot. I think one build
>    error per .c file should be enough to attract attention. Though
>    I'll add a comment to convert_bpf_extensions() that build_bug_on
>    errors should be addressed in two places.

and to that you replied:
"My concern would be that in case the code gets changed, this spot
could easily be overlooked by someone possibly unfamiliar with the
code, since no build error triggers there."

so from there I saw two options: either copy paste all
build_bug_on and have the same *insn=... and build_bug_on in
two places or consolidate them in single helper function.
Obviously single helper function is a preferred method.
I'm not sure what are you still arguing about.
