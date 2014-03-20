From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 20 Mar 2014 13:40:21 +0100
Message-ID: <20140320124021.GA2946@minipsycho.orion>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
 <532AD5B3.6020205@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:58421 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbaCTMk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 08:40:28 -0400
Received: by mail-ee0-f48.google.com with SMTP id b57so610263eek.35
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 05:40:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <532AD5B3.6020205@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 20, 2014 at 12:49:07PM CET, jhs@mojatatu.com wrote:
>Hi Jiri,
>
>On 03/19/14 11:33, Jiri Pirko wrote:
>>This is just an early draft, RFC. I wanted to post this early to get the
>>feedback as soon as possible.
>>
>>The basic idea is to introduce a generic infractructure to support various
>>switch chips in kernel. Also the idea is to benefit of currently existing
>>Open vSwitch userspace infrastructure.
>>
>
>
>I think the abstraction should be a netdev and to be specific the
>bridge - not openvswitch. Our current tools like ifconfig, iproute2,
>bridge etc should continue to work.

That is exactly the case. Nothing is specific to OVS. OVS is just a one
method to access the switchdev api.

Abstraction is netdev. One netdev per each switch port and one netdev as
a master on the top of that representing the switch itself.


>In my experience, it is sufficient to model a switch after the linux
>bridge at the basic level if the starting point is
>L2 (which is the lowest common denominator).
>And then you add capabilities that different chips expose.
>Not every chip can do vxlan, flows etc. And we already know how
>to abstract those out.
>My  experience on top of broadcom chips is the approach i described
>works rather well.
>
>Additionally, note:
>We do have L2 devices that offload in the kernel
>(refer to DSA, posting earlier from the openwrt guys, and
>the intel devices which do VDMQ etc). I am now counting we have 5
>different approaches if we add yours.

I think that the problem is that each solution serves different purpose.
For example DSA is for switches connected as a PHY to a MAC. That is
completely different case to what my switchdev API is trying to handle.


>
>cheers,
>jamal
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
