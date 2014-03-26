From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 19:03:56 +0100
Message-ID: <20140326180356.GK2869@minipsycho.orion>
References: <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com>
 <5332677F.2090404@cumulusnetworks.com>
 <5332B1FE.7080102@mojatatu.com>
 <53330639.8050403@cumulusnetworks.com>
 <20140326165934.GH2869@minipsycho.orion>
 <533312A3.5070600@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:60609 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaCZSEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 14:04:00 -0400
Received: by mail-ee0-f49.google.com with SMTP id c41so1960668eek.36
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 11:03:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <533312A3.5070600@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 26, 2014 at 06:47:15PM CET, roopa@cumulusnetworks.com wrote:
>On 3/26/14, 9:59 AM, Jiri Pirko wrote:
>>Wed, Mar 26, 2014 at 05:54:17PM CET, roopa@cumulusnetworks.com wrote:
>>>On 3/26/14, 3:54 AM, Jamal Hadi Salim wrote:
>>>>On 03/26/14 01:37, Roopa Prabhu wrote:
>>>>>On 3/25/14, 1:11 PM, Florian Fainelli wrote:
>>>>>>2014-03-25 12:35 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
>>>>>Sorry about getting on this thread late and possibly in the middle.
>>>>>Agree on the idea of keeping the ports linked to the master switch dev
>>>>>(or the 'conduit' to the switch chip) via private list instead of the
>>>>>master-slave relationship proposed earlier.
>>>>>By private i mean the netdev->priv linkage to the master switch dev and
>>>>>not really keeping the ports from being exposed to the user.
>>>>>
>>>>>We think its better to keep the switch ports exposed as any other netdev
>>>>>on linux.
>>>>>  This approach will make the switch ports look exactly like a nic port
>>>>>and all tools will continue to work seamlessly. The switch port
>>>>>operations could internally be forwarded to the switch netdev (sw1 in
>>>>>the above case).
>>>>>
>>>>>example:
>>>>>$ip link set dev sw1p0 up
>>>>>$ethtool -S sw1p0
>>>>>
>>>>I like the approach. I know the above is a simple version, but i am
>>>>assuming you also mean i can do things like
>>>>ip route add ...
>>>>bridge fdb add ... (and if you like your brctl go ahead)
>>>>bonding ...
>>>>
>>>yes, exactly.  We support this model on our boxes today.
>>>User can bond switch ports on our box in the exact same way as he/she
>>>would bond two nic ports.
>>>Our 'conduit to switch chip' reflects the corresponding lag
>>>configuration in the switch chip.
>>>Same goes for bridging, routing, acls.
>>
>>So you implement bonding netlink api? Or you hook into bonding driver
>>itselt? Can you show us the code?
>We use the netlink API and libnl. In our current model, our switch
>chip driver listens to netlink notifications and programs the switch
>chip. The switch chip driver uses libnl caches and libnl netlink apis
>to reflect the kernel state to switch chip.


So when you configure for example bonding over 2 ports, you actually use
bonding driver to do that. And you userspace app listens to
notifications and programs the switch chip accordingly. Am I close?

How about data? Is this new "bonding" interface able to assign ip to is
and send/receive packets.

I'm still not sure I understand your concept. Do you have some
documentation for it available?

>
>Thanks,
>Roopa
>
>
