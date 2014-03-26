From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 08:24:26 +0100
Message-ID: <20140326072426.GC2869@minipsycho.orion>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
 <532AD5B3.6020205@mojatatu.com>
 <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:50932 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbaCZHYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 03:24:30 -0400
Received: by mail-ee0-f47.google.com with SMTP id b15so1286154eek.34
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 00:24:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140325173927.GE8102@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 25, 2014 at 06:39:27PM CET, nhorman@tuxdriver.com wrote:
>On Mon, Mar 24, 2014 at 07:07:35PM -0400, Jamal Hadi Salim wrote:
>> On 03/22/14 05:48, Jiri Pirko wrote:
>> >Fri, Mar 21, 2014 at 01:04:20PM CET, jhs@mojatatu.com wrote:
>> 
>> >Hmm. This got me thinking about netdev and switches well and perhaps the
>> >switchdev api could be mostly implemented by couple of more ndos and
>> >feature flags. That way we could stick to your immortal netdev :)
>> >
>> >
>> 
>> Perhaps ;->
>> 
>> >>
>> >>In my view: that (immortal) device for L2/bridging is the bridge or
>> >>maybe a more barebone version of the bridge (since it has gained a
>> >>little more weight in recent times).
>> >
>> >Well, I do not think that bridge is ideal abstraction for modern switch
>> >chips. Bridge is very limited.
>> >
>> 
>> True - but i was more thinking of being inclusive of the smaller
>> devices. They are mostly L2 only and in very limited scope. And thats
>> probably 95% of the population. The things you are talking about
>> are very high end and they can do more. Florian's taxanomy was useful.
>> 
>> >But I don't necessary think it is needed to "mask" as a bride or mimic a
>> >bridge in any way. DSA does not do that either.
>No, but it would be really nice if these smaller devices could take advantage of
>this infrastructure.  Looking at it, I don't see why thats not possible.  The
>big trick (as we've discussed in the past), is using a net_device structure to
>take advantage of all the features that net_devices offer while not enabling the
>device specific features that some hardware doesn't allow.
>
>For instance the broadcom chips that live in many wireless routers would be well
>served by the model jiri has here as far as Media level interface control is
>concerned (i.e. ifup/down/speed/duplex/etc), but its a bit lacking in that
>net_devices are assumed to support L3 protocol configuration (i.e. they can have
>ip addresses assigned to them), which you can't IIRC do on these chips.
>
>Would it be worth considering a private interface model?  That is to say:

I'm personaly strongly againts this. All netdevices should stay under net
namespace list. If you break this, I expect many unexpected issues.
+ There is not really a reason for this breakage.


>
>1) Ports on a switch chip are accessed using net_device structures, but
>registered to a private list contained within the switch device, rather than to
>the net namespaces device list.
>
>2) Access to the switch ports via user space is done through the master switch
>interface with additional netlink attributes specifying the port on the switch
>to access (or not to access the master switch device directly)
>
>
>Such a model I think might fit well with Jiri's code here and provide greater
>flexibility for a wider range of devices.  It would of course require
>augmentation for user space, but the changes would be additive, so I think they
>would be reasonable.  This would also allow the switch device to have a hook in
>the control path to block or allow features that the hardware may or may not
>support while still being able to use the existing net_device infrastructure to
>support these operations as they are normally carried out.
>
>Best
>Neil
>
