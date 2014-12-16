From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
 bridge port attributes
Date: Tue, 16 Dec 2014 08:41:51 -0800
Message-ID: <549060CF.5020706@gmail.com>
References: <1418202320-19491-3-git-send-email-roopa@cumulusnetworks.com> <20141210093755.GB1863@nanopsycho.orion> <5489CBBA.7050302@cumulusnetworks.com> <20141211171145.GG1912@nanopsycho.orion> <5489DB73.1080808@cumulusnetworks.com> <20141211180743.GA2010@nanopsycho.orion> <5489E214.4080708@cumulusnetworks.com> <20141211222559.GB1880@nanopsycho.orion> <548D9B14.9010201@cumulusnetworks.com> <20141214153549.GA2174@nanopsycho.orion> <548DE7E2.6010705@cumulusnetworks.com> <548EFD94.8070905@mojatatu.com> <E4CD12F19ABA0C4D8729E087A761DC3505D999EA@ORSMSX106.amr.corp.intel.com> <548F20FF.9080508@gmail.com> <E4CD12F19ABA0C4D8729E087A761DC3505D9FA8C@ORSMSX106.amr.corp.intel.com> <548F6E62.1040500@mojatatu.com> <E4CD12F19ABA0C4D8729E087A761DC3505DA6149@ORSMSX101.amr.corp.intel.com> <548F88E8.1010703
 @cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505DB15CA@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>, "tgraf@suug.ch" <tgraf@suug.ch>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:46849 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbaLPQmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 11:42:10 -0500
Received: by mail-oi0-f45.google.com with SMTP id a141so9847118oig.4
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 08:42:10 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505DB15CA@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2014 03:01 AM, Arad, Ronen wrote:
>
> In my reply (inline) I elaborate on the validity of bridge-less and offloaded-bridge models for L2 switching.
>
> I also discuss the implied necessity of a bridge device for L3 routing and potential issues with the upcoming FIB offloading proposal.
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Roopa Prabhu
>> Sent: Tuesday, December 16, 2014 3:21 AM
>> To: Arad, Ronen
>> Cc: Jamal Hadi Salim; John Fastabend; netdev@vger.kernel.org; Jiri Pirko;
>> sfeldma@gmail.com; bcrl@kvack.org; tgraf@suug.ch;
>> stephen@networkplumber.org; linville@tuxdriver.com;
>> vyasevic@redhat.com; davem@davemloft.net;
>> shm@cumulusnetworks.com; gospo@cumulusnetworks.com
>> Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
>> bridge port attributes
>>
>> On 12/15/14, 4:58 PM, Arad, Ronen wrote:
>>>
>>>> -----Original Message-----
>>>> From: Jamal Hadi Salim [mailto:jhs@mojatatu.com]
>>>> Sent: Tuesday, December 16, 2014 1:28 AM
>>>> To: Arad, Ronen; John Fastabend; netdev@vger.kernel.org
>>>> Cc: Roopa Prabhu; Jiri Pirko; sfeldma@gmail.com; bcrl@kvack.org;
>>>> tgraf@suug.ch; stephen@networkplumber.org; linville@tuxdriver.com;
>>>> vyasevic@redhat.com; davem@davemloft.net;
>> shm@cumulusnetworks.com;
>>>> gospo@cumulusnetworks.com
>>>> Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and
>>>> del bridge port attributes
>>>>
>>>> On 12/15/14 13:36, Arad, Ronen wrote:
>>>>>
>>>>>> -----Original Message-----
>>>>> The behavior of a driver could depend on the presence of a bridge
>>>>> and
>>>> features such as FDB LEARNING and LEARNING_SYNC.
>>>>
>>>> Indeed, those are bridge attributes.
>>>>
>>>>> A switch port driver which is not enslaved to a bridge might need to
>>>>> implement VLAN-aware FDB within the driver and report its content to
>>>>> user-
>>>> space using ndo_fdb_dump.
>>>>    >
>>>>> A switch port driver which is enslaved to a bridge could do with
>>>>> only pass through for static FDB configuration
>>>>    > to the HW when LEARNING_SYNC is configured. FDB reporting to
>>>> user- space and soft aging are left to the bridge module FDB.
>>>>> Such driver, without LEARNING_SYNC could still avoid maintaing
>>>>> in-driver
>>>> FDB as long as it could dump the HW FDB on demand.
>>>>> LEARNING_SYNC also requires periodic updates of freshness
>>>>> information
>>>> from the driver to the bridge module.
>>>>
>>>> If you have an fdb - shouldnt that be exposed only if you have a
>>>> bridge abstraction exposed? i.e thats where the Linux tools would work.
>>> I'm trying to find out what are the opinions of other people in the netdev
>> list.
>>> John have clearly stated that he'd like to see full L2 switching functionality
>> (at least) supported without making a bridge device mandatory.
>>> The existing bridge ndos (ndo_bridge_{set,del,get}link) already support that
>> with proper setting of SELF/MASTER flags by iproute2.
>>> I see the value in supporting both approaches (bridge device mandatory
>>> and bridge device optional). If the choice is left to user-driven policy decision,
>>> we need to document both use models and map traditional L2 features to
>>> each model.
>>> The L2 offloading (or NETFUNC as it is currently called), which is being
>>> discussed on a different patch-set, is only needed when a bridge device is
>>> used.
>>> Without a bridge device, all configuration has to be targeted at the switch
>>> port driver directly using the SELF flag. FDB remains relevant and it is used to
>>> configure static MAC table entries and dump the HW MAC table.
>
>> Your understanding is right here. So far all patches have kept both models in
>> mind.
>
>
>>> When the HW device is a L2 switch or a multi-layer switch (L2-L3 or even
>>> higher), there is a gap between what the HW is doing and what is explicitly
>>> modeled in Linux.
>
>
>> Can you elaborate more here ?. We use the linux model to accelerate a
>> multi-layer (l2-l3) switch today. There maybe a few gaps, but these gaps can
>> be closed by having equivalent functionality in the software path.
>
> What I meant is that without a bridge device the HW switch is seen as a collection of independent switch ports. Typical switch ASIC performs L2 switching by default. This is not expressed explicitly in Linux without a bridge device.
> The SELF flag is used to target typical bridge port and bridge configuration at a switch port device.
> Without an explicit bridge device, bridge attributes have to be directed at an arbitrary port (any port could represent the entire switch) and interpreted by the switch port driver as intended for the entire switch (this includes attributes like STP etc.)
> Each switch port device driver has to implement similar functionality (i.e. all bridge and fdb related ndos) independently without common functionality shared (e.g. FDB, soft aging).
> It is a valid use model and could avoid the complexity of having to deal with the presence of both SW and HW bridge and to deal with explicit offloading of data-path.
>
> I was trying to find out whether the intention was to continue and support both bridge-less an offloaded-bridge models and leave it to the end-user to choose the desirable model at configuration time.
> This would require dual support in the switch port driver in order to have best user experience across multiple switch ASICs or other kinds of devices.
>

I'm still missing why there is duplicate implementations in the driver.
If the driver implements the set of ndo ops why should it care who calls
them? I think you tried to explain this already but I'm not seeing it.

[...]

I'll need to think about the l3 stuff but I think Jiri/Scott/Roopa
might have worked some of it out.

-- 
John Fastabend         Intel Corporation
