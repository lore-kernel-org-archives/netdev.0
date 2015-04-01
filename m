From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v2 01/26] switchdev: introduce get/set attrs
 ops
Date: Wed, 01 Apr 2015 08:19:00 -0400
Message-ID: <551BE234.2060308@mojatatu.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com> <1427882882-2533-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:34223 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbbDAMTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 08:19:02 -0400
Received: by iedfl3 with SMTP id fl3so45978629ied.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 05:19:02 -0700 (PDT)
In-Reply-To: <1427882882-2533-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/15 06:07, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Add two new swdev ops for get/set switch port attributes.  Most swdev
> interactions on a port are gets or sets on port attributes, so rather than
> adding ops for each attribute, let's define clean get/set ops for all
> attributes, and then we can have clear, consistent rules on how attributes
> propagate on stacked devs.
>
> Add the basic algorithms for get/set attr ops.  Use the same recusive algo to
> walk lower devs we've used for STP updates, for example.  For get, compare attr
> value for each lower dev and only return success if attr values match across
> all lower devs.

So this GET is very specific? All underlying children have to have the
exact same value?
My impression of GET is, depending on the target object, i retrieve
one thing or a lot of things that probably user space is asking for.
I wasnt getting that impression looking at this code.

  For sets, set the same attr value for all lower devs.  If
> something goes wrong on one of the lower devs, revert all back to previous attr
> value.

And from staring at the code - the reverting could fail as well..

>
> If lower dev recusion isn't desired, allow a flag SWDEV_F_NO_RECURSE to
> indicate get/set only work on port (lowest) device.
>
> On set, allow a flag SWDEV_F_NO_RECOVER to turn off automatic err recovery.
>


uh-oh did i read that last one correctly?;-> I dont see it in the code
but are you now allowing for policy to dictate whether we want something
atomic or not? That should be a generic much higher level flag imo.
Note, I am for supporting the different scenarios but i thought
the initial approach was all transactions are atomic (all-or-nothing).

Also why invent new namespace for these switch attributes? They all seem
to have netlink IDs already. I note in patches afterwards are using the
netlink IDs.

cheers,
jamal
