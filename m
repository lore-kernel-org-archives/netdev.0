From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] tc: bpf: generalize pedit action
Date: Sun, 29 Mar 2015 18:18:01 -0700
Message-ID: <5518A449.605@plumgrid.com>
References: <1427424837-7757-1-git-send-email-ast@plumgrid.com> <55189E5F.3050302@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55189E5F.3050302-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/29/15 5:52 PM, Jamal Hadi Salim wrote:
> On 03/26/15 22:53, Alexei Starovoitov wrote:
>> existing TC action 'pedit' can munge any bits of the packet.
>> Generalize it for use in bpf programs attached as cls_bpf and act_bpf via
>> bpf_skb_store_bytes() helper function.
>>
>> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>> ---
>>
>> pedit is limited to 32-bit masked rewrites. Here let it be flexible.
>>
>> ptr = skb_header_pointer(skb, offset, len, buf);
>> memcpy(ptr, from, len);
>> if (ptr == buf)
>>    skb_store_bits(skb, offset, ptr, len);
>>
>> ^^ logic is the same as in pedit.
>> shifts, mask, invert style of rewrite is easily done by the program.
>> Just like arbitrary parsing of the packet and applying rewrites on
>> demand.
>>
>
> Alexei/Daniel - I am backlogged on email; however, i didn quiet follow:
> Is there another patch to pedit that help achieve the above?

not really. If you meant adding 'array of bytes' attribute to pedit, it
won't be sufficient from program point of view. Programs are deciding
what and when to write, whereas pedit is static.
I'm working on csum helper patch and a set of examples that will
demonstrate the possibilities. I believe Daniel is preparing examples
as well for different use cases.
