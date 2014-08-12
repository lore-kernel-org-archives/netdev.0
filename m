From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] Made bpf_internal_load_pointer_neg_helper static: fixes
 Sparse warning
Date: Mon, 11 Aug 2014 17:57:23 -0700
Message-ID: <CAADnVQKbYheiRF_fmUnUUfSQgxUupY5vrjcjwimwwy-gnGhz2w@mail.gmail.com>
References: <1405708449.11800.2.camel@oc1318858833.ibm.com>
	<1407794456.12335.3.camel@oc1318858833.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	dany@us.ibm.com, dany4madden@gmail.com, benjamin.fik.lee@gmail.com
To: Benjamin Lee <leeben@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407794456.12335.3.camel@oc1318858833.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 11, 2014 at 3:00 PM, Benjamin Lee <leeben@linux.vnet.ibm.com> wrote:
> I wanted to know what the current status of my patch is since my
> internship will be ending this Friday and I want to know before then. if
> there are any problems with it I can fix them before Thursday. Thank you
> in advance.

using scripts/get_maintainer.pl for cc list would have helped to
receive response sooner.

> On Fri, 2014-07-18 at 11:34 -0700, Benjamin Lee wrote:
>> This patch fixes the following Sparse warning:
>>
>> net/core/filter.c:52:6: warning: symbol
>> 'bpf_internal_load_pointer_neg_helper' was not declared. Should it be
>> static?
>>
>> I declared bpf_internal_load_pointer_neg_helper as static because it
>> is not referenced elsewhere in the kernel. The patched kernel boots

the patch is incorrect, since this function is called out of assembler.
Try 'git grep bpf_internal_load_pointer_neg_helper'

>> and runs OK. I verified that the section of code is actually being

your kernel likely compiled ok, because you don't have
CONFIG_BPF_JIT=y in your .config
For this reason doing 'make allmodconfig' is recommended.

>> compiled by temporarily placing a #pragma message inside the function.
>> I also verified that the function is being called by temporarily
>> inserting a call to panic.
>>
>> I am a high school student trying to become familiar with the open
>> source process and the Linux kernel, so your guidance is appreciated.
>>
>> Signed-off-by Benjamin Lee <leeben@linux.vnet.ibm.com>
>> Reviewed-by: Dany Madden <danymadden@us.ibm.com>
>> Reviewed-by: Jim Keniston <jkenisto@us.ibm.com>
>>
>> ---
>>   net/core/filter.c |    3 ++-
>>   1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/core/filter.c b/net/core/filter.c
>> index 735fad8..068442a 100644
>> --- a/net/core/filter.c
>> +++ b/net/core/filter.c
>> @@ -70,7 +70,8 @@
>>    *
>>    * Exported for the bpf jit load helper.
>>    */
>> -void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
>> +static void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb,
>> +                                                 int k, unsigned int
>> size)
>>   {
>>         u8 *ptr = NULL;
>>
