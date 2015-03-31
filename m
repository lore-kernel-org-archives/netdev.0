From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
Date: Tue, 31 Mar 2015 08:37:43 -0700
Message-ID: <551ABF47.5030508@cumulusnetworks.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com> <1427704836-8776-3-git-send-email-sfeldma@gmail.com> <E4CD12F19ABA0C4D8729E087A761DC35067FAA25@ORSMSX101.amr.corp.intel.com> <CAE4R7bA4qBk2mXa=A3fg=j+c-w6cHPYhPHVkdhJo=LUW4FX7YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36350 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbbCaPho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 11:37:44 -0400
Received: by padcy3 with SMTP id cy3so23005712pad.3
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 08:37:44 -0700 (PDT)
In-Reply-To: <CAE4R7bA4qBk2mXa=A3fg=j+c-w6cHPYhPHVkdhJo=LUW4FX7YA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/15, 5:38 PM, Scott Feldman wrote:
> On Mon, Mar 30, 2015 at 5:22 PM, Arad, Ronen <ronen.arad@intel.com> wrote:
>>
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>> Behalf Of sfeldma@gmail.com
>>> Sent: Monday, March 30, 2015 1:40 AM
>>> To: netdev@vger.kernel.org
>>> Cc: jiri@resnulli.us; roopa@cumulusnetworks.com; linux@roeck-us.net;
>>> f.fainelli@gmail.com
>>> Subject: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
>>>
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>> [cut]
>>> int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
>>> {
>>> -      return -EOPNOTSUPP;
>>> +      struct swdev_attr prev = *attr;
>>> +      int err, get_err;
>>> +
>>> +      get_err = swdev_port_attr_get(dev, &prev);
>>> +
>>> +      err = _swdev_port_attr_set(dev, attr);
>>> +      if (err && !get_err && !(attr->flags & SWDEV_ATTR_F_NO_RECOVER))
>>> +              /* Some err on set: revert to previous value */
>>> +              _swdev_port_attr_set(dev, &prev);
>> Netlink requests could contain multiple attributes within a single request.
>> Reverting to the previous value applies only to the first
>> swdev_port_attr_set error. It does not rollback all prior changes that
>> were triggered by the same Netlink request.
> Since attr_set scope is a single attr across ports, it can only revert
> that attr for those ports.  So rewinding multiple attributes needs to
> happen above attr_set.  I guess we could have a multi_attr_set that
> takes an array of *attrs, but something like this can be built on top
> of attr_set.  Maybe baby steps is best first so we can see how things
> shape up.
Having a multi attr set/del is necessary in some cases where the hw api 
may be able to handle more than one attr set/del. I can see this 
especially in the vlan case. Having the driver get all attributes and do 
the necessary optimizations to program hardware might be better.

thanks,
Roopa
