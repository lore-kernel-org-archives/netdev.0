From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Tue, 1 Nov 2016 09:46:43 +0100
Message-ID: <20161101084643.GA1707@nanopsycho.orion>
References: <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com>
 <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
 <20161031093922.GA2895@nanopsycho.orion>
 <58177712.4000208@gmail.com>
 <20161031171229.GB2895@nanopsycho.orion>
 <58179CE4.2080400@gmail.com>
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
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37012 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1168043AbcKAIqr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 04:46:47 -0400
Received: by mail-wm0-f47.google.com with SMTP id t79so94321306wmt.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 01:46:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <58179CE4.2080400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 31, 2016 at 08:35:00PM CET, john.fastabend@gmail.com wrote:
>[...]
>
>>>>
>>>
>>> I think the issue with offloading a P4-AST will be how much work goes
>>> into mapping this onto any particular hardware instance. And how much
>>> of the P4 language feature set is exposed.
>>>
>>> For example I suspect MLX switch has a different pipeline than MLX NIC
>>> and even different variations of the product lines. The same goes for
>>> Intel pipeline in NIC and switch and different products in same line.
>>>
>>> If P4-ast describes the exact instance of the hardware its an easy task
>>> the map is 1:1 but isn't exactly portable. Taking an N table onto a M
>>> table pipeline on the other hand is a bit more work and requires various
>>> transformations to occur in the runtime API. I'm guessing the class of
>>> devices we are talking about here can not reconfigure themselves to
>>> match the P4-ast.
>> 
>> I believe we can assume that. the p4ast has to be generic as the
>> original p4source is. It would be a terrible mistake to couple it with
>> some specific hardware. I only want to use p4ast because it would be easy
>> parse in kernel, unlike p4source.
>
>Sure but in the fixed ASIC cases the universe of P4 programs is much
>larger than the handful of ones that can be 'accepted' by the device. So
>you really need to have some knowledge of the hardware. However if you
>believe (guessing from last bullet) that devices will be configurable
>in the future then its more likely that the hardware can 'accept' the
>program.
>
>> 
>> 
>>>
>>> In the naive implementation only pipelines that map 1:1 will work. Maybe
>>> this is what Alexei is noticing?
>> 
>> P4 is ment to program programable hw, not fixed pipeline.
>> 
>
>I'm guessing there are no upstream drivers at the moment that support
>this though right? The rocker universe bits though could leverage this.

mlxsw. But this is naturaly not implemented yet, as there is no
infrastructure.


>
>> 
>>>
>>>>
>>>>> since I cannot see how one can put the whole p4 language compiler
>>>>> into the driver, so this last step of p4ast->hw, I presume, will be
>>>>> done by firmware, which will be running full compiler in an embedded cpu
>>>>
>>>> In case of mlxsw, that compiler would be in driver.
>>>>
>>>>
>>>>> on the switch. To me that's precisely the kernel bypass, since we won't
>>>>> have a clue what HW capabilities actually are and won't be able to fine
>>>>> grain control them.
>>>>> Please correct me if I'm wrong.
>>>>
>>>> You are wrong. By your definition, everything has to be figured out in
>>>> driver and FW does nothing. Otherwise it could do "something else" and
>>>> that would be a bypass? Does not make any sense to me whatsoever.
>>>>
>>>>
>>>>>
>>>>>> Plus the thing I cannot imagine in the model you propose is table fillup.
>>>>>> For ebpf, you use maps. For p4 you would have to have a separate HW-only
>>>>>> API. This is very similar to the original John's Flow-API. And therefore
>>>>>> a kernel bypass.
>>>>>
>>>>> I think John's flow api is a better way to expose mellanox switch capabilities.
>>>>
>>>> We are under impression that p4 suits us nicely. But it is not about
>>>> us, it is about finding the common way to do this.
>>>>
>>>
>>> I'll just poke at my FlowAPI question again. For fixed ASICS what is
>>> the Flow-API missing. We have a few proof points that show it is both
>>> sufficient and usable for the handful of use cases we care about.
>> 
>> Yeah, it is most probably fine. Even for flex ASICs to some point. The
>> question is how it stands comparing to other alternatives, like p4
>> 
>
>Just to be clear the Flow-API _was_ generated from the initial P4 spec.
>The header files and tools used with it were autogenerated ("compiled"
>in a loose sense) from the P4 program. The piece I never exposed
>was the set_* operations to reconfigure running systems. I'm not sure
>how valuable this is in practice though.
>
>Also there is a P4-16 spec that will be released shortly that is more
>flexible and also more complex.

Would it be able to easily extend the Flow-API to include the changes?


>
>> 
>>>
>>>>
>>>>> I also think it's not fair to call it 'bypass'. I see nothing in it
>>>>> that justify such 'swear word' ;)
>>>>
>>>> John's Flow-API was a kernel bypass. Why? It was a API specifically
>>>> designed to directly work with HW tables, without kernel being involved.
>>>
>>> I don't think that is a fair definition of HW bypass. The SKIP_SW flag
>>> does exactly that for 'tc' based offloads and it was not rejected.
>> 
>> No, no, no. You still have possibility to do the same thing in kernel,
>> same functionality, with the same API. That is a big difference.
>> 
>> 
>>>
>>> The _real_ reason that seems to have fallen out of this and other
>>> discussion is the Flow-API didn't provide an in-kernel translation into
>>> an emulated patch. Note we always had a usermode translation to eBPF.
>>> A secondary reason appears to be overhead of adding yet another netlink
>>> family.
>> 
>> Yeah. Maybe you remember, back then when Flow-API was being discussed,
>> I suggested to wrap it under TC as cls_xflows and cls_xflowsaction of
>> some sort and do in-kernel datapath implementation. I believe that after
>> that, it would be acceptable.
>> 
>
>As I understand the thread here that is exactly the proposal here right?
>With a discussion around if the structures/etc are sufficient or any
>alternative representations exist.

Might be the way, yes. But I fear that with other p4 extensions this
might not be easy to align with. Therefore I though about something more
generic, like the p4ast.


>
>> 
>>>
>>>>
>>>>
>>>>> The goal of flow api was to expose HW features to user space, so that
>>>>> user space can program it. For something simple as mellanox switch
>>>>> asic it fits perfectly well.
>>>>
>>>> Again, this is not mlx-asic-specific. And again, that is a kernel bypass.
>>>>
>>>>
>>>>> Unless I misunderstand the bigger goal of this discussion and it's
>>>>> about programming ezchip devices.
>>>>
>>>> No. For network processors, I believe that BPF is nicely offloadable, no
>>>> need to do the excercise for that.
>>>>
>>>>
>>>>>
>>>>> If the goal is to model hw tcam in the linux kernel then just introduce
>>>>> tcam bpf map type. It will be dog slow in user space, but it will
>>>>> match exactly what is happnening in the HW and user space can make
>>>>> sensible trade-offs.
>>>>
>>>> No, you got me completely wrong. This is not about the TCAM. This is
>>>> about differences in the 2 words (p4/bpf).
>>>> Again, for "p4-ish" devices, you have to translate BPF. And as you
>>>> noted, it's an instruction set. Very hard if not impossible to parse in
>>>> order to get back the original semantics.
>>>>
>>>
>>> I think in this discussion "p4-ish" devices means devices with multiple
>>> tables in a pipeline? Not devices that have programmable/configurable
>>> pipelines right? And if we get to talking about reconfigurable devices
>>> I believe this should be done out of band as it typically means
>>> reloading some ucode, etc.
>> 
>> I'm talking about both. But I think we should focus on reconfigurable
>> ones, as we probably won't see that much fixed ones in the future.
>> 
>
>hmm maybe but the 10/40/100Gbps devices are going to be around for some
>time. So we need to ensure these work well.

Yes, but I would like to emphasize, if we are defining new api
the primary focus should be on new devices.
