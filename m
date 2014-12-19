From: B Viswanath <marichika4@gmail.com>
Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch port configuration
Date: Fri, 19 Dec 2014 10:44:57 +0530
Message-ID: <CAN+pFwJyfg1+=+tXUpon0Kket56HJ=9BR3XohPhZnaX7hfPgpg@mail.gmail.com>
References: <C4896FB061E7DE4AAC93031BDCA044B104AD7B82@IRSMSX108.ger.corp.intel.com>
	<5492E85C.6010802@cumulusnetworks.com>
	<C4896FB061E7DE4AAC93031BDCA044B104AD9E53@IRSMSX108.ger.corp.intel.com>
	<5492EFC3.8030102@cumulusnetworks.com>
	<C4896FB061E7DE4AAC93031BDCA044B104ADA16F@IRSMSX108.ger.corp.intel.com>
	<549313B8.6050102@cumulusnetworks.com>
	<C4896FB061E7DE4AAC93031BDCA044B104ADA310@IRSMSX108.ger.corp.intel.com>
	<54931969.7040209@cumulusnetworks.com>
	<5493293A.2000802@intel.com>
	<54935E28.8050602@cumulusnetworks.com>
	<549362A5.3000808@intel.com>
	<549367CC.2080307@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Varlese, Marco" <marco.varlese@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <549367CC.2080307@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19 December 2014 at 05:18, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> On 12/18/14, 3:26 PM, Samudrala, Sridhar wrote:
>>
>>
>> On 12/18/2014 3:07 PM, Roopa Prabhu wrote:
>>>
>>> On 12/18/14, 11:21 AM, John Fastabend wrote:
>>>>
>>>> On 12/18/2014 10:14 AM, Roopa Prabhu wrote:
>>>>>
>>>>> On 12/18/14, 10:02 AM, Varlese, Marco wrote:
>>>>>>
>>>>>> Removed unnecessary content for ease of reading...
>>>>>>
>>>>>>>>>>>> +/* Switch Port Attributes section */
>>>>>>>>>>>> +
>>>>>>>>>>>> +enum {
>>>>>>>>>>>> +    IFLA_ATTR_UNSPEC,
>>>>>>>>>>>> +    IFLA_ATTR_LEARNING,
>>>>>>>>>>>
>>>>>>>>>>> Any reason you want learning here ?. This is covered as part  of
>>>>>>>>>>> the bridge setlink attributes.
>>>>>>>>>>>
>>>>>>>>>> Yes, because the user may _not_ want to go through a bridge
>>>>>>>>>> interface
>>>>>>>>>
>>>>>>>>> necessarily.
>>>>>>>>> But, the bridge setlink/getlink interface was changed to
>>>>>>>>> accommodate
>>>>>>>
>>>>>>> 'self'
>>>>>>>>>
>>>>>>>>> for exactly such cases.
>>>>>>>>> I kind of understand your case for the other attributes (these are
>>>>>>>>> per port settings that switch asics provide).
>>>>>>>>>
>>>>>>>>> However, i don't understand the reason to pull in bridge attributes
>>>>>>>>> here.
>>>>>>>>>
>>>>>>>> Maybe, I am missing something so you might help. The learning
>>>>>>>> attribute -
>>>>>>>
>>>>>>> in my case - it is like all other attributes: a port attribute (as
>>>>>>> you said, port
>>>>>>> settings that the switch provides per port).
>>>>>>>>
>>>>>>>> So, what I was saying is "why the user shall go through a bridge to
>>>>>>>> configure
>>>>>>>
>>>>>>> the learning attribute"? From my perspective, it is as any other
>>>>>>> attribute and
>>>>>>> as such configurable on the port.
>>>>>>>
>>>>>>> Thinking about this some more, i don't see why any of these
>>>>>>> attributes
>>>>>>> (except loopback. I dont understand the loopback attribute) cant be
>>>>>>> part of
>>>>>>> the birdge port attributes.
>>>>>>>
>>>>>>> With this we will end up adding l2 attributes in two places: the
>>>>>>> general link
>>>>>>> attributes and bridge attributes.
>>>>>>>
>>>>>>> And since we have gone down the path of using
>>>>>>> ndo_bridge_setlink/getlink
>>>>>>> with 'self'....we should stick to that for all l2 attributes.
>>>>>>>
>>>>>>> The idea of overloading ndo_bridge_set/getlink, was to have the same
>>>>>>> set of
>>>>>>> attributes but support both cases where the user wants to go through
>>>>>>> the
>>>>>>> bridge driver or directly to the switch port driver. So, you are not
>>>>>>> really going
>>>>>>> through the bridge driver if you use 'self' and
>>>>>>> ndo_bridge_setlink/getlink.
>>>>>>>
>>>>>> Roopa, one of the comments I got from Thomas Graf on my v1 patch
>>>>>> was that your patch and mine were supplementary ("I think Roopa's
>>>>>> patches are supplementary. Not all switchdev users will be backed
>>>>>> with a Linux Bridge. I therefore welcome your patches very
>>>>>> much")... I also understood by others that the patch made sense for
>>>>>> the same reason. I simply do not understand why these attributes
>>>>>> (and maybe others in the future) could not be configured directly
>>>>>> on a standard port but have to go through a bridge.
>>>>>>
>>>>> ok, i am very confused in that case. The whole moving of bridge
>>>>> attributes from the bridge driver to rtnetlink.c was to make the
>>>>> bridge attributes accessible to any driver who wants to set l2/bridge
>>>>> attributes on their switch ports. So, its unclear to me why we are
>>>>> doing this parallel thing again. This move to rtnetlink.c was done
>>>>> during the recent rocker support. so, maybe scott/jiri can elaborate
>>>>> more.
>>>>
>>>>
>>>> Not sure if this will add to the confusion or help. But you do not
>>>> need to have the bridge.ko loaded or netdev's attached to a bridge
>>>> to use the setlink/getlink ndo ops and netlink messages.
>>>>
>>>> This was intentionally done. Its already used with NIC devices to
>>>> configure embedded bridge settings such as VEB/VEPA.
>>>
>>>
>>> that helps my case, thanks.
>>
>>
>> So the user interface to set/get the per-port attributes will be via
>> 'bridge', not 'ip'
>>
>>     bridge link set dev sw0p1 port_attr bcast_flooding 1 self
>>     bridge link get dev sw0p1 port_attr bcast_flooding self
>
>
> yes, l2 attributes.
>>
>>
>> We also need an interface to set per-switch attributes. Can this work?
>>     bridge link set dev sw0 sw_attr bcast_flooding 1 master
>> where sw0 is a bridge representing the hardware switch.
>
>
> Not today. We discussed this @ LPC, and one way to do this would be to have
> a device
> representing the switch asic. This is in the works.


Can I assume that on  platforms which house more than one asic (say
two 24 port asics, interconnected via a 10G link or equivalent, to get
a 48 port 'switch') , the 'rocker' driver (or similar) should expose
them as a single set of ports, and not as two 'switch ports' ?

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
