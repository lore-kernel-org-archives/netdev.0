From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/3] net: bpf: consolidate JIT binary allocator
Date: Mon, 08 Sep 2014 10:12:27 +0200
Message-ID: <540D64EB.1000609@redhat.com>
References: <1409996567-2170-1-git-send-email-dborkman@redhat.com> <1409996567-2170-2-git-send-email-dborkman@redhat.com> <20140908061744.GA4193@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@plumgrid.com, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbaIHIMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 04:12:37 -0400
In-Reply-To: <20140908061744.GA4193@osiris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2014 08:17 AM, Heiko Carstens wrote:
> On Sat, Sep 06, 2014 at 11:42:45AM +0200, Daniel Borkmann wrote:
>> Introduced in commit 314beb9bcabf ("x86: bpf_jit_comp: secure bpf jit
>> against spraying attacks") and later on replicated in aa2d2c73c21f
>> ("s390/bpf,jit: address randomize and write protect jit code") for
>> s390 architecture, write protection for BPF JIT images got added and
>> a random start address of the JIT code, so that it's not on a page
>> boundary anymore.
>>
>> Since both use a very similar allocator for the BPF binary header,
>> we can consolidate this code into the BPF core as it's mostly JIT
>> independant anyway.
>>
>> This will also allow for future archs that support DEBUG_SET_MODULE_RONX
>> to just reuse instead of reimplementing it.
>>
>> While reviewing the code, I think on s390, the alignment masking
>> seems not to be correct in it's current form, that is, we make sure
>> the first instruction starts at an even address as stated by commit
>> aa2d2c73c21f but masks the start with '& -2' while 2 byte-alignment
>> should rather be '& ~1'.
>>
>> JIT tested on x86_64 and s390x with BPF test suite.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> ---
>>   arch/s390/net/bpf_jit_comp.c | 45 ++++++++-------------------------------
>>   arch/x86/net/bpf_jit_comp.c  | 50 ++++++++++----------------------------------
>>   include/linux/filter.h       | 13 ++++++++++++
>>   kernel/bpf/core.c            | 39 ++++++++++++++++++++++++++++++++++
>>   4 files changed, 72 insertions(+), 75 deletions(-)
>
> Looks good to me (except for the comment about s390 ;).

Yes, sorry for that. I guess I had too much coffee. :) I have already
updated the commit message and resent the set.

> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Thanks a lot,
Daniel
