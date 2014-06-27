From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 2/2] powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT
 test
Date: Fri, 27 Jun 2014 11:46:32 +0200
Message-ID: <53AD3D78.4000005@redhat.com>
References: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>   <1403717697-3911-2-git-send-email-kda@linux-powerpc.org>  <1403771455.18572.8.camel@concordia> <53ABDB72.9020902@redhat.com> <1403845697.21873.1.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752603AbaF0Jqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2014 05:46:42 -0400
In-Reply-To: <1403845697.21873.1.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2014 07:08 AM, Michael Ellerman wrote:
> On Thu, 2014-06-26 at 10:36 +0200, Daniel Borkmann wrote:
>> On 06/26/2014 10:30 AM, Michael Ellerman wrote:
>>> On Wed, 2014-06-25 at 21:34 +0400, Denis Kirjanov wrote:
>>>> We have to return the boolean here if the tag presents
>>>> or not, not just ANDing the TCI with the mask which results to:
>>>>
>>>> [  709.412097] test_bpf: #18 LD_VLAN_TAG_PRESENT
>>>> [  709.412245] ret 4096 != 1
>>>> [  709.412332] ret 4096 != 1
>>>> [  709.412333] FAIL (2 times)
>>>
>>> Hi Denis,
>>>
>>> Is this the same version of test_bpf that is in Linus' tree?
>>>
>>> I don't see any fails with that version, am I missing something?
>>>
>>>     [  187.690640] test_bpf: #18 LD_VLAN_TAG_PRESENT 46 50 PASS
>>
>> Did you try to modprobe test_bpf after enabling JIT, i.e. :
>>
>>     echo 1 > /proc/sys/net/core/bpf_jit_enable
>>
>> Last time I tested with ppc64, I saw the interpreter passing
>> while JIT failed, which the fix above should address.
>
> Right, I thought CONFIG_BPF_JIT=y was sufficient.
>
> But that just makes it available, I need to *also* enable it at runtime.

Yes, it's an extra runtime knob which still needs to be enabled by
the admin for security reasons. This knob also allows you to enable
the debugging interface `echo 2 >/proc/sys/net/core/bpf_jit_enable`
where the disassembly can be read out via: tools/net/bpf_jit_disasm.c
