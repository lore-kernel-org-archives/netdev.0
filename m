From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Let's do P4
Date: Wed, 2 Nov 2016 08:18:06 -0700
Message-ID: <581A03AE.8050006@gmail.com>
References: <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
 <20161031093922.GA2895@nanopsycho.orion> <58177712.4000208@gmail.com>
 <20161031171229.GB2895@nanopsycho.orion> <58179CE4.2080400@gmail.com>
 <20161101084643.GA1707@nanopsycho.orion> <5818B11C.2040004@gmail.com>
 <20161102080723.GD1713@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
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
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33114 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755734AbcKBPSe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:18:34 -0400
Received: by mail-pf0-f175.google.com with SMTP id d2so13715032pfd.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:18:34 -0700 (PDT)
In-Reply-To: <20161102080723.GD1713@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-02 01:07 AM, Jiri Pirko wrote:
> Tue, Nov 01, 2016 at 04:13:32PM CET, john.fastabend@gmail.com wrote:
>> [...]
>>
>>>>> P4 is ment to program programable hw, not fixed pipeline.
>>>>>
>>>>
>>>> I'm guessing there are no upstream drivers at the moment that support
>>>> this though right? The rocker universe bits though could leverage this.
>>>
>>> mlxsw. But this is naturaly not implemented yet, as there is no
>>> infrastructure.
>>
>> Really? What is re-programmable?
>>
>> Can the parse graph support arbitrary parse graph?
>> Can the table topology be reconfigured?
>> Can new tables be created?
>> What about "new" actions being defined at configuration time?
>>
>> Or is this just the normal TCAM configuration of defining key widths and
>> fields.
> 
> At this point TCAM configuration.
> 

OK so before we go down the path to enable a full fledged P4 interface
we need a consumer for sure. We shouldn't add all this complexity until
someone steps up to use it. A runtime API is sufficient for TCAM config.

[...]

>>
>> P4-16 will allow externs, "functions" to execute in the control flow and
>> possibly inside the parse graph. None of this was considered in the
>> Flow-API. So none of this is supported.
>>
>> I still have the question are you trying to push the "programming" of
>> the device via 'tc' or just the runtime configuration of tables? If it
>> is just runtime Flow-API is sufficient IMO. If its programming the
>> device using the complete P4-16 spec than no its not sufficient. But
> 
> Sure we need both.
> 

See above.

> 
>> I don't believe vendors will expose the complete programmability of the
>> device in the driver, this is going to look more like a fw update than
>> a runtime change at least on the devices I'm aware of.
> 
> Depends on driver. I think it is fine if driver processed it into come
> hw configuration sequence or it simply pushed the program down to fw.
> Both usecases are legit.
> 

At this point I don't think the entire P4 capabilities will be exposed
as an API but more along the lines of an FPGA bitstream or firmware
update.


[...]

>>
>> Same question as above are we _really_ talking about pushing the entire
>> programmability of the device via 'tc'. If so we need to have a vendor
>> say they will support and implement this?
> 
> We need some API, and I believe that TC is perfectly suitable for that.
> Why do you think it's a problem?
> 

For runtime configuration completely agree. For device configuration
I don't see the advantage of adding an entire device specific compiler
in the driver. The device is a set of CAMs, TCAMs, ALUs, instruction
caches, etc. its not like a typical NIC/switch where you just bang
some registers. Unless its all done in firmware but that creates an
entirely different set of problems like how to update your compiler.

Bottom line we need to have a proof point of a driver in kernel
to see exactly how a P4 configuration would work. Again runtime config
and device topology/capabilities discovery I'm completely on board.

Thanks,
John
