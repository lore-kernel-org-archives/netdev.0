From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Mon, 31 Oct 2016 18:12:29 +0100
Message-ID: <20161031171229.GB2895@nanopsycho.orion>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com>
 <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
 <20161031093922.GA2895@nanopsycho.orion>
 <58177712.4000208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Thomas Graf <tgraf@suug.ch>, Jakub Kicinski <kubakici@wp.pl>,
        netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com,
        Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38579 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944861AbcJaRMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:12:32 -0400
Received: by mail-wm0-f54.google.com with SMTP id n67so241342710wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 10:12:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <58177712.4000208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 31, 2016 at 05:53:38PM CET, john.fastabend@gmail.com wrote:
>On 16-10-31 02:39 AM, Jiri Pirko wrote:
>> Sun, Oct 30, 2016 at 11:39:05PM CET, alexei.starovoitov@gmail.com wrote:
>>> On Sun, Oct 30, 2016 at 05:38:36PM +0100, Jiri Pirko wrote:
>>>> Sun, Oct 30, 2016 at 11:26:49AM CET, tgraf@suug.ch wrote:
>>>>> On 10/30/16 at 08:44am, Jiri Pirko wrote:
>>>>>> Sat, Oct 29, 2016 at 06:46:21PM CEST, john.fastabend@gmail.com wrote:
>>>>>>> On 16-10-29 07:49 AM, Jakub Kicinski wrote:
>>>>>>>> On Sat, 29 Oct 2016 09:53:28 +0200, Jiri Pirko wrote:
>>>>>>>>> Hi all.
>>>>>>>>>
>>>
>>> sorry for delay. travelling to KS, so probably missed something in
>>> this thread and comments can be totally off...
>>>
>>> the subject "let's do P4" is imo misleading, since it reads like
>>> we don't do P4 at the moment, whereas the opposite is true.
>>> Several p4->bpf compilers is a proof.
>> 
>> We don't do p4 in kernel now, we don't do p4 offloading now. That is
>> the reason I started this discussion.
>> 
>
>The point here is P4 is a high level language likely we will never "do"
>P4 in the kernel nor offload it. P4 translates to eBPF and runs in
>kernel just fine. This can be offloaded to some devices but as you
>point out is challenging for a class of architecture to offload.
>
>Also simple P4 programs can be offloaded into 'tc' cls_u32 for example
>and even cls_flower.
>
>> 
>>>
>>>> The network world is divided into 2 general types of hw:
>>>> 1) network ASICs - network specific silicon, containing things like TCAM
>>>>    These ASICs are suitable to be programmed by P4.
>>>
>>> i think the opposite is the case in case of P4.
>>> when hw asic has tcam it's still far far away from being usable with P4
>>> which requires fully programmable protocol parser, arbitrary tables and so on.
>>> P4 doesn't even define TCAM as a table type. The p4 program can declare
>>> a desired algorithm of search in the table and compiler has to figure out
>>> what HW resources to use to satisfy such p4 program.
>>>
>>>> 2) network processors - basically a general purpose CPUs
>>>>    These processors are suitable to be programmed by eBPF.
>>>
>>> I think this statement is also misleading, since it positions
>>> p4 and bpf as competitors whereas that's not the case.
>>> p4 is the language. bpf is an instruction set.
>> 
>> I wanted to say that we are having 2 approaches in silicon, 2 different
>> paradigms. Sure you can do p4>bpf. But hard to do it the opposite way.
>> 
>> 
>>>
>>>> Exactly. Following drawing shows p4 pipeline setup for SW and Hw:
>>>>
>>>>                                  |
>>>>                                  |               +--> ebpf engine
>>>>                                  |               |
>>>>                                  |               |
>>>>                                  |           compilerB
>>>>                                  |               ^
>>>>                                  |               |
>>>> p4src --> compilerA --> p4ast --TCNL--> cls_p4 --+-> driver -> compilerC -> HW
>>>>                                  |
>>>>                        userspace | kernel
>>>>                                  |
>>>
>>> frankly this diagram smells very much like kernel bypass to me,
>> 
>> what? That is well defined kernel API, in-kernel sw consumer and offload
>> in driver. Same API for both.
>> 
>> Alex, you have very odd sense about what's bypassing kernel. That kind
>> of freaks me out...
>> 
>
>I think the issue with offloading a P4-AST will be how much work goes
>into mapping this onto any particular hardware instance. And how much
>of the P4 language feature set is exposed.
>
>For example I suspect MLX switch has a different pipeline than MLX NIC
>and even different variations of the product lines. The same goes for
>Intel pipeline in NIC and switch and different products in same line.
>
>If P4-ast describes the exact instance of the hardware its an easy task
>the map is 1:1 but isn't exactly portable. Taking an N table onto a M
>table pipeline on the other hand is a bit more work and requires various
>transformations to occur in the runtime API. I'm guessing the class of
>devices we are talking about here can not reconfigure themselves to
>match the P4-ast.

I believe we can assume that. the p4ast has to be generic as the
original p4source is. It would be a terrible mistake to couple it with
some specific hardware. I only want to use p4ast because it would be easy
parse in kernel, unlike p4source.


>
>In the naive implementation only pipelines that map 1:1 will work. Maybe
>this is what Alexei is noticing?

P4 is ment to program programable hw, not fixed pipeline.


>
>> 
>>> since I cannot see how one can put the whole p4 language compiler
>>> into the driver, so this last step of p4ast->hw, I presume, will be
>>> done by firmware, which will be running full compiler in an embedded cpu
>> 
>> In case of mlxsw, that compiler would be in driver.
>> 
>> 
>>> on the switch. To me that's precisely the kernel bypass, since we won't
>>> have a clue what HW capabilities actually are and won't be able to fine
>>> grain control them.
>>> Please correct me if I'm wrong.
>> 
>> You are wrong. By your definition, everything has to be figured out in
>> driver and FW does nothing. Otherwise it could do "something else" and
>> that would be a bypass? Does not make any sense to me whatsoever.
>> 
>> 
>>>
>>>> Plus the thing I cannot imagine in the model you propose is table fillup.
>>>> For ebpf, you use maps. For p4 you would have to have a separate HW-only
>>>> API. This is very similar to the original John's Flow-API. And therefore
>>>> a kernel bypass.
>>>
>>> I think John's flow api is a better way to expose mellanox switch capabilities.
>> 
>> We are under impression that p4 suits us nicely. But it is not about
>> us, it is about finding the common way to do this.
>> 
>
>I'll just poke at my FlowAPI question again. For fixed ASICS what is
>the Flow-API missing. We have a few proof points that show it is both
>sufficient and usable for the handful of use cases we care about.

Yeah, it is most probably fine. Even for flex ASICs to some point. The
question is how it stands comparing to other alternatives, like p4


>
>> 
>>> I also think it's not fair to call it 'bypass'. I see nothing in it
>>> that justify such 'swear word' ;)
>> 
>> John's Flow-API was a kernel bypass. Why? It was a API specifically
>> designed to directly work with HW tables, without kernel being involved.
>
>I don't think that is a fair definition of HW bypass. The SKIP_SW flag
>does exactly that for 'tc' based offloads and it was not rejected.

No, no, no. You still have possibility to do the same thing in kernel,
same functionality, with the same API. That is a big difference.


>
>The _real_ reason that seems to have fallen out of this and other
>discussion is the Flow-API didn't provide an in-kernel translation into
>an emulated patch. Note we always had a usermode translation to eBPF.
>A secondary reason appears to be overhead of adding yet another netlink
>family.

Yeah. Maybe you remember, back then when Flow-API was being discussed,
I suggested to wrap it under TC as cls_xflows and cls_xflowsaction of
some sort and do in-kernel datapath implementation. I believe that after
that, it would be acceptable.


>
>> 
>> 
>>> The goal of flow api was to expose HW features to user space, so that
>>> user space can program it. For something simple as mellanox switch
>>> asic it fits perfectly well.
>> 
>> Again, this is not mlx-asic-specific. And again, that is a kernel bypass.
>> 
>> 
>>> Unless I misunderstand the bigger goal of this discussion and it's
>>> about programming ezchip devices.
>> 
>> No. For network processors, I believe that BPF is nicely offloadable, no
>> need to do the excercise for that.
>> 
>> 
>>>
>>> If the goal is to model hw tcam in the linux kernel then just introduce
>>> tcam bpf map type. It will be dog slow in user space, but it will
>>> match exactly what is happnening in the HW and user space can make
>>> sensible trade-offs.
>> 
>> No, you got me completely wrong. This is not about the TCAM. This is
>> about differences in the 2 words (p4/bpf).
>> Again, for "p4-ish" devices, you have to translate BPF. And as you
>> noted, it's an instruction set. Very hard if not impossible to parse in
>> order to get back the original semantics.
>> 
>
>I think in this discussion "p4-ish" devices means devices with multiple
>tables in a pipeline? Not devices that have programmable/configurable
>pipelines right? And if we get to talking about reconfigurable devices
>I believe this should be done out of band as it typically means
>reloading some ucode, etc.

I'm talking about both. But I think we should focus on reconfigurable
ones, as we probably won't see that much fixed ones in the future.
