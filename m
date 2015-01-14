From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: fix setlink/dellink notifications
Date: Wed, 14 Jan 2015 15:56:02 -0800
Message-ID: <54B70212.5050705@cumulusnetworks.com>
References: <1421218123-18346-1-git-send-email-roopa@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505DEE86A@ORSMSX101.amr.corp.intel.com> <54B6FD60.8020106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:60672 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbbANX4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 18:56:03 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so13637283pad.13
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 15:56:03 -0800 (PST)
In-Reply-To: <54B6FD60.8020106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/15, 3:36 PM, John Fastabend wrote:
> On 01/14/2015 03:22 PM, Arad, Ronen wrote:
>>
>>
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org 
>>> [mailto:netdev-owner@vger.kernel.org] On
>>> Behalf Of roopa@cumulusnetworks.com
>>> Sent: Tuesday, January 13, 2015 10:49 PM
>>> To: netdev@vger.kernel.org; shemminger@vyatta.com; vyasevic@redhat.com;
>>> john.fastabend@gmail.com; tgraf@suug.ch; jhs@mojatatu.com; 
>>> sfeldma@gmail.com;
>>> jiri@resnulli.us
>>> Cc: wkok@cumulusnetworks.com
>>> Subject: [PATCH net-next] bridge: fix setlink/dellink notifications
>>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>> [..]
>
> [...]
>
>>>             err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
>>> -
>>> -        if (!err)
>>> +        if (!err) {
>>>             flags &= ~BRIDGE_FLAGS_SELF;
>>> +
>>> +            /* Generate event to notify upper layer of bridge
>>> +             * change
>>> +             */
>>> +            if (!err)
>>> +                err = rtnl_bridge_notify(dev, oflags);
>>> +        }
>>>     }
>>>
>>>     if (have_flags)
>>>         memcpy(nla_data(attr), &flags, sizeof(flags));
>>
>> What is the purpose of the above two lines (not changed by the patch)?
>> They seem to copy over the flags with the successfully applied cases
>> (MASTER and/or SELF) flags cleared back into the incoming netlink 
>> message.
>> I could not figure any place where the modified flags attribute is used
>
> This allows userspace to learn which operation failed when it is an
> operation to set both the software bridge via BRIDGE_FLAGS_MASTER and
> the the hardware via BRIDGE_FLAGS_SELF. When we get the error back
> software looks at the flags to figure out how to recover/retry/etc.
Ah ok, I was also wondering why that was there,

thanks,
Roopa
