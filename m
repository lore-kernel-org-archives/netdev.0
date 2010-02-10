From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next-2.6 PATCH v3 4/5] rtnetlink: Add VF config code to
 rtnetlink
Date: Wed, 10 Feb 2010 15:33:29 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE3CBE343@rrsmsx501.amr.corp.intel.com>
References: <20100210114303.14483.71368.stgit@localhost.localdomain>
 <20100210114403.14483.11004.stgit@localhost.localdomain>
 <4B72A061.40905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Patrick McHardy <kaber@trash.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:30309 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755837Ab0BJWdh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 17:33:37 -0500
In-Reply-To: <4B72A061.40905@trash.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Patrick McHardy [mailto:kaber@trash.net]
[snip]
>
>We usually encapsulate lists of the same attribute type in another
>top-level attribute. Check out the IFLA_VLAN_*_QOS attributes for
>an example.
>
>The interface should also be symetrical, IOW you should dump the
>same attributes used in the userspace->kernel direction instead
>of a combined "info" attribute.

Sheesh, Patrick, where were you three months ago when I first
posted this stuff? It would have helped a lot if I heard from
you back then. We've had at least five internal review cycles
here and nobody caught this, mostly because nobody understands
it.

That being said, I'll take another look at the NLA_NESTED stuff
and see what I can figure out. Do you know of any place (outside
of the code) where this is documented?  It's particularly
difficult to follow this code.

I see your point about symmetrical interfaces, but I'm not sure
it's the best thing here. We want the user to be able to set these
attributes independently, without blowing away any other settings.
If we put all three settings together into one data structure,
the code flow will end up being much more complicated.

I'd prefer to leave the data structures as they are, and switch
to using nested attributes for the status reporting part, i.e.
what happens when you type 'ip link show'. Would this work for you?

>
>It dev_base_lock really correct here? This is running under the RTNL, so
>changes to the device list can't happen.
>

Good catch - I'll pull out the lock.


>> +		if (ops->ndo_set_vf_mac)
>> +			err = ops->ndo_set_vf_mac(dev, ivm->vf, ivm->mac);
>
>Shouldn't this indicate an error if the attributes aren't supported?

Yes. I'll fix this.

>The casts aren't necessary. But why does struct ifla_vf_vlan use u32
>for the vlan in the first place?

I used u32 for all of the values because that's what everything else
used. All the stuff in iproute2 seems to like u32 size as well.

The casts aren't necessary for the compiler, but I put them in for
readability purposes - to make it obvious. I can remove them if 
they're objectionable.

Thanks for your review, Patrick.

-Mitch
