From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH v2 0/5] MIPS: BPF: JIT fixes and improvements.
Date: Tue, 14 Mar 2017 15:59:01 -0700
Message-ID: <1bbf9439-bdc4-1d5f-ee55-c8caed106e19@caviumnetworks.com>
References: <20170314212144.29988-1-david.daney@cavium.com>
 <20170314224946.GA11983@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@imgtec.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Daney <david.daney@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314224946.GA11983@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/14/2017 03:49 PM, Alexei Starovoitov wrote:
> On Tue, Mar 14, 2017 at 02:21:39PM -0700, David Daney wrote:
>> Changes from v1:
>>
>>   - Use unsigned access for SKF_AD_HATYPE
>>
>>   - Added three more patches for other problems found.
>>
>>
>> Testing the BPF JIT on Cavium OCTEON (mips64) with the test-bpf module
>> identified some failures and unimplemented features.
>>
>> With this patch set we get:
>>
>>      test_bpf: Summary: 305 PASSED, 0 FAILED, [85/297 JIT'ed]
>>
>> Both big and little endian tested.
>>
>> We still lack eBPF support, but this is better than nothing.
>>
>> David Daney (5):
>>   MIPS: uasm:  Add support for LHU.
>>   MIPS: BPF: Add JIT support for SKF_AD_HATYPE.
>>   MIPS: BPF: Use unsigned access for unsigned SKB fields.
>>   MIPS: BPF: Quit clobbering callee saved registers in JIT code.
>>   MIPS: BPF: Fix multiple problems in JIT skb access helpers.
>
> Thanks. Nice set of fixes. Especially patch 4.
> Did you see crashes because of it?

Only when running the test-bpf module.

The "JMP_JA: Jump, gap, jump, ..." test doesn't actually use any 
registers, which I think is somewhat uncommon in BPF code.  The system 
would either crash or have weird behavior after running this test.




> Acked-by: Alexei Starovoitov <ast@kernel.org>
>
