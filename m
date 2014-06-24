From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH 2/2] powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT test
Date: Tue, 24 Jun 2014 18:52:49 +0400
Message-ID: <CAOJe8K2qRyW7DPynyLhfdms5AjWHeMd5-fBm7TMkobSj-E_yDg@mail.gmail.com>
References: <1403603969-24436-1-git-send-email-kda@linux-powerpc.org>
	<1403603969-24436-2-git-send-email-kda@linux-powerpc.org>
	<53A989CA.9030405@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36540 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbaFXOwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 10:52:50 -0400
Received: by mail-ob0-f178.google.com with SMTP id wn1so451581obc.37
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 07:52:50 -0700 (PDT)
In-Reply-To: <53A989CA.9030405@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/24/14, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 06/24/2014 01:59 PM, Denis Kirjanov wrote:
>
>> We have to return the boolean here if the tag presents
>> or not, not jusr ORing the TCI with the mask which results to:
>
>> [  709.412097] test_bpf: #18 LD_VLAN_TAG_PRESENT
>> [  709.412245] ret 4096 != 1
>> [  709.412332] ret 4096 != 1
>> [  709.412333] FAIL (2 times)
>
>     You need to sign off on the patch, else it won't be applied.

Oh, right. Moreover I've made a mistake in the description (we're ANDing)

Thanks!

>> ---
>>   arch/powerpc/net/bpf_jit_comp.c | 4 +++-
>>   1 file changed, 3 insertions(+), 1 deletion(-)
>
>> diff --git a/arch/powerpc/net/bpf_jit_comp.c
>> b/arch/powerpc/net/bpf_jit_comp.c
>> index af0ed4d..a3d8f58 100644
>> --- a/arch/powerpc/net/bpf_jit_comp.c
>> +++ b/arch/powerpc/net/bpf_jit_comp.c
>> @@ -394,8 +394,10 @@ static int bpf_jit_build_body(struct sk_filter *fp,
>> u32 *image,
>>   							  vlan_tci));
>>   			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
>>   				PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
>> -			else
>> +			else {
>
>     All arms of the *if* statement should have {} if one branch has {}.
>
>>   				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
>> +				PPC_SRWI(r_A, r_A, 12);
>> +			}
>>   			break;
>>   		case BPF_ANC | SKF_AD_QUEUE:
>>   			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
>
> WBR, Sergei
>
>
