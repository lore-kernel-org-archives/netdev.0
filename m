From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Wed, 15 Mar 2017 17:43:44 +0530
Message-ID: <CAHgaXdJL92XRjHae2Nb9j9SerSe65=N=ErDHTQf23sdBxwthzw@mail.gmail.com>
References: <20170130103853.GA34633@in3o.xyz> <CAGXu5j+7+D=N8U9Zpq1Uq526B4C4g=gQZtQ1iCMt3juDFgfgJA@mail.gmail.com>
 <CAHgaXd+nj69n-Xf46N=4M-j-0hKHVrrLfsvRZCG=2CCAtVF6ZA@mail.gmail.com>
 <CAGXu5j+NSLomuSgD40kys+pWc+J9aB6Bbk_gSP9Lp_ScimQn_w@mail.gmail.com>
 <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com> <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>, Mircea Gherzan <mgherzan@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-7038-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Hi kees,

> It seems like you're suggesting truncating the 64-bit register values?
> I think your best solution is going to be to use a memory scratch
> space and build 64-bit operations using 32-bit registers and memory
> operations.

Yes. I was suggesting the truncating of 64-bit register values, but
for 32 bit operands only. So when I am truncating the BPF register, I
am getting rid of non-useful bytes only.

 Can you explain how to use memory scratch space and build 64-bit
operations using 32-bit registers and memory operations ? A small
example would help a lot.

>> - Similarly, For all BPF_ALU class instructions.
>> - For BPF_ADD, I will mask the addition result to 32 bit only.
>>  I am not sure, Overflow might be a problem.
>> - For BPF_SUB, I will mask the subtraction result to 32 bit only.
>>  I am not sure, Underflow might be problem.
>> - For BPF_MUL, similar to BPF_ADD. Overflow Problem ?
>> - For BPF_DIV, 32 bit masking should be fine, I guess.
>> - For BPF_OR, BPF_AND, BPF_XOR, BPF_LSH, BPF_RSH, BPF_MOD 32 bit
>>  masking should be fine.
>> - For BPF_NEG and BPF_ARSH, might be a problem because of the sign bit.
>> - For BPF_END, 32 bit masking should work fine.
>>  Let me know if any of the above point is wrong or need your suggestion.
>>
>> - Although, for ALU instructions, there is a big problem of register
>>   flag manipulations. Generally, architecture's ABI takes care of this
>>   part but as we are doing 64 bit Instructions emulation(kind of) on 32
>>   bit machine, it needs to be done manually. Does that sound correct ?
>
> You can't truncate, but you'll have to build 64-bit ops using 32-bit registers.

A small example would help a lot.
>
>>
>> - I am not JITing BPF_ALU64 class instructions as of now. As we have to
>>   take care of atomic instructions and race conditions with these
>>   instruction which looks complicated to me as of now. Will try to figure out
>>   this part and implement it later. Currently, I will just let it be
>>   interpreted by the ebpf interpreter.
>>
>> - For BPF_JMP class, I am assuming that, although eBPF is 64 bit ABI,
>>   the address pointers on 32 bit arch like arm will be of 32 bit only.
>>   So, for BPF_JMP, masking the 64 bit destination address to 32 bit
>>   should do the trick and no address will be corrupted in this way. Am I
>>   correct to assume this ?
>>   Also, I need to check for address getting out of the allowed memory
>>   range.
>
> That's probably true, but the JIT should likely detect a truncation
> here, if you're going to depend on it, and reject the BPF.

Okay. So I guess I have to use memory for this as well ?
An example would be great.

>
>> - For BPF_LD, BPF_LDX, BPF_ST and BPF_STX class instructions, I am
>>   assuming the same thing as above - All addresses and pointers are 32
>>   bit - which can be taken care just by maksing the eBPF register
>>   values. Does that sound correct ?
>>   Also, I need to check for the address overflow, address getting out
>>   of the allowed memory range and things like that.
>
> I'd say, get something working and send a patch -- that's likely the
> best way to get more detailed feedback. :)
I would love to but I have to understand what to implement first.


-Shubham
