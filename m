From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] bridge: fix setlink/dellink notifications
Date: Wed, 14 Jan 2015 15:36:00 -0800
Message-ID: <54B6FD60.8020106@gmail.com>
References: <1421218123-18346-1-git-send-email-roopa@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505DEE86A@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:40299 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbbANXgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 18:36:31 -0500
Received: by mail-ob0-f174.google.com with SMTP id wo20so890802obc.5
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 15:36:31 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505DEE86A@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2015 03:22 PM, Arad, Ronen wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of roopa@cumulusnetworks.com
>> Sent: Tuesday, January 13, 2015 10:49 PM
>> To: netdev@vger.kernel.org; shemminger@vyatta.com; vyasevic@redhat.com;
>> john.fastabend@gmail.com; tgraf@suug.ch; jhs@mojatatu.com; sfeldma@gmail.com;
>> jiri@resnulli.us
>> Cc: wkok@cumulusnetworks.com
>> Subject: [PATCH net-next] bridge: fix setlink/dellink notifications
>>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
> [..]

[...]

>> 			err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
>> -
>> -		if (!err)
>> +		if (!err) {
>> 			flags &= ~BRIDGE_FLAGS_SELF;
>> +
>> +			/* Generate event to notify upper layer of bridge
>> +			 * change
>> +			 */
>> +			if (!err)
>> +				err = rtnl_bridge_notify(dev, oflags);
>> +		}
>> 	}
>>
>> 	if (have_flags)
>> 		memcpy(nla_data(attr), &flags, sizeof(flags));
>
> What is the purpose of the above two lines (not changed by the patch)?
> They seem to copy over the flags with the successfully applied cases
> (MASTER and/or SELF) flags cleared back into the incoming netlink message.
> I could not figure any place where the modified flags attribute is used

This allows userspace to learn which operation failed when it is an
operation to set both the software bridge via BRIDGE_FLAGS_MASTER and
the the hardware via BRIDGE_FLAGS_SELF. When we get the error back
software looks at the flags to figure out how to recover/retry/etc.

.John

-- 
John Fastabend         Intel Corporation
