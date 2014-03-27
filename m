From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 27 Mar 2014 17:10:42 +0100
Message-ID: <20140327161042.GM2845@minipsycho.orion>
References: <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com>
 <5332677F.2090404@cumulusnetworks.com>
 <5332B1FE.7080102@mojatatu.com>
 <53330639.8050403@cumulusnetworks.com>
 <20140326165934.GH2869@minipsycho.orion>
 <533312A3.5070600@cumulusnetworks.com>
 <20140326180356.GK2869@minipsycho.orion>
 <53334629.5030208@cumulusnetworks.com>
 <20140326213130.GA32193@minipsycho.orion>
 <5334454D.9050108@cumulusnetworks.com>
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
Received: from mail-ee0-f50.google.com ([74.125.83.50]:44395 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbaC0QKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:10:47 -0400
Received: by mail-ee0-f50.google.com with SMTP id c13so3070073eek.37
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:10:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5334454D.9050108@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 27, 2014 at 04:35:41PM CET, roopa@cumulusnetworks.com wrote:
>On 3/26/14, 2:31 PM, Jiri Pirko wrote:
>>Wed, Mar 26, 2014 at 10:27:05PM CET, roopa@cumulusnetworks.com wrote:
>>>On 3/26/14, 11:03 AM, Jiri Pirko wrote:
>>>>Wed, Mar 26, 2014 at 06:47:15PM CET, roopa@cumulusnetworks.com wrote:
>>>>>On 3/26/14, 9:59 AM, Jiri Pirko wrote:
>>>>>>Wed, Mar 26, 2014 at 05:54:17PM CET, roopa@cumulusnetworks.com wrote:
>>>>>>>On 3/26/14, 3:54 AM, Jamal Hadi Salim wrote:
>>>>>>>>On 03/26/14 01:37, Roopa Prabhu wrote:
>>>>>>>>>On 3/25/14, 1:11 PM, Florian Fainelli wrote:
>>>>>>>>>>2014-03-25 12:35 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
>>>>>>>>>Sorry about getting on this thread late and possibly in the middle.
>>>>>>>>>Agree on the idea of keeping the ports linked to the master switch dev
>>>>>>>>>(or the 'conduit' to the switch chip) via private list instead of the
>>>>>>>>>master-slave relationship proposed earlier.
>>>>>>>>>By private i mean the netdev->priv linkage to the master switch dev and
>>>>>>>>>not really keeping the ports from being exposed to the user.
>>>>>>>>>
>>>>>>>>>We think its better to keep the switch ports exposed as any other netdev
>>>>>>>>>on linux.
>>>>>>>>>  This approach will make the switch ports look exactly like a nic port
>>>>>>>>>and all tools will continue to work seamlessly. The switch port
>>>>>>>>>operations could internally be forwarded to the switch netdev (sw1 in
>>>>>>>>>the above case).
>>>>>>>>>
>>>>>>>>>example:
>>>>>>>>>$ip link set dev sw1p0 up
>>>>>>>>>$ethtool -S sw1p0
>>>>>>>>>
>>>>>>>>I like the approach. I know the above is a simple version, but i am
>>>>>>>>assuming you also mean i can do things like
>>>>>>>>ip route add ...
>>>>>>>>bridge fdb add ... (and if you like your brctl go ahead)
>>>>>>>>bonding ...
>>>>>>>>
>>>>>>>yes, exactly.  We support this model on our boxes today.
>>>>>>>User can bond switch ports on our box in the exact same way as he/she
>>>>>>>would bond two nic ports.
>>>>>>>Our 'conduit to switch chip' reflects the corresponding lag
>>>>>>>configuration in the switch chip.
>>>>>>>Same goes for bridging, routing, acls.
>>>>>>So you implement bonding netlink api? Or you hook into bonding driver
>>>>>>itselt? Can you show us the code?
>>>>>We use the netlink API and libnl. In our current model, our switch
>>>>>chip driver listens to netlink notifications and programs the switch
>>>>>chip. The switch chip driver uses libnl caches and libnl netlink apis
>>>>>to reflect the kernel state to switch chip.
>>>>So when you configure for example bonding over 2 ports, you actually use
>>>>bonding driver to do that. And you userspace app listens to
>>>>notifications and programs the switch chip accordingly. Am I close?
>>>yes correct.
>>>>How about data? Is this new "bonding" interface able to assign ip to is
>>>>and send/receive packets.
>>>yes
>>>>I'm still not sure I understand your concept. Do you have some
>>>>documentation for it available?
>>>>
>>>I think the only documentation available today in this area is the
>>>user guide and that in-turn points to native linux command manpages
>>>iproute2, sysfs, debian ifupdown etc.
>>>I will see if i can find anything else.
>>I ment the architecture design documentation. linux manpages are not
>>that interesting to me :)
>>
>yes, i get that and thats why i did not include a pointer to our user
>guide. :).
>Sorry, the easiest thing to find right now was a high level marketing
>diagram and here you go:
>http://cumulusnetworks.com/product/architecture/. This is nothing but
>what i mentioned in my emails.
>From here the details involve nothing but programming the broadcom
>asic. This is mostly broadcom details/documentation.
>
>The above is our current working/shipping model.
>
>In our second phase of implementation, We wanted to preserve the
>above user interface model (which people using our boxes are very
>fond of), but introduce the concept of a switchdev and switchports in
>the kernel.
>We had a switchdev api in the works ourselves which we were planning
>to publish on netdev until you beat us to it.
>Our version is similar to yours but it reflects some of the points
>that i have brought up in my previous emails.
>It probably looks more like your v2 (patch 4/6) without the
>master/slave link.

Yes, I was thinking about this some more and I plan to remove this
implicit master/slave link in the next version.


>We can share some code in the comming weeks. It does need some
>cleanup and i am also waiting for scott feldman who is on vacation
>this week.
>
>I know you are looking for specifics, but we don't have switchdev
>code to create a bond in switch chip asic yet. But we have been
>thinking about the details and the current thought there at a high
>level was, we would add a netdev op which the bonding driver could
>redirect to the switchdev driver when it has slaves with
>IFF_SWITCH_PORT set.

I was thinking about this as well. I believe that if this have to be
done, it should be done on RTNL level, not as a hack to
bond/bridge/whatever code.

>
>Thanks,
>Roopa
>
>
>
