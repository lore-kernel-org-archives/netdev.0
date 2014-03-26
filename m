From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 26 Mar 2014 10:47:15 -0700
Message-ID: <533312A3.5070600@cumulusnetworks.com>
References: <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36071 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbaCZRr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 13:47:26 -0400
In-Reply-To: <20140326165934.GH2869@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/26/14, 9:59 AM, Jiri Pirko wrote:
> Wed, Mar 26, 2014 at 05:54:17PM CET, roopa@cumulusnetworks.com wrote:
>> On 3/26/14, 3:54 AM, Jamal Hadi Salim wrote:
>>> On 03/26/14 01:37, Roopa Prabhu wrote:
>>>> On 3/25/14, 1:11 PM, Florian Fainelli wrote:
>>>>> 2014-03-25 12:35 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
>>>> Sorry about getting on this thread late and possibly in the middle.
>>>> Agree on the idea of keeping the ports linked to the master switch dev
>>>> (or the 'conduit' to the switch chip) via private list instead of the
>>>> master-slave relationship proposed earlier.
>>>> By private i mean the netdev->priv linkage to the master switch dev and
>>>> not really keeping the ports from being exposed to the user.
>>>>
>>>> We think its better to keep the switch ports exposed as any other netdev
>>>> on linux.
>>>>   This approach will make the switch ports look exactly like a nic port
>>>> and all tools will continue to work seamlessly. The switch port
>>>> operations could internally be forwarded to the switch netdev (sw1 in
>>>> the above case).
>>>>
>>>> example:
>>>> $ip link set dev sw1p0 up
>>>> $ethtool -S sw1p0
>>>>
>>> I like the approach. I know the above is a simple version, but i am
>>> assuming you also mean i can do things like
>>> ip route add ...
>>> bridge fdb add ... (and if you like your brctl go ahead)
>>> bonding ...
>>>
>> yes, exactly.  We support this model on our boxes today.
>> User can bond switch ports on our box in the exact same way as he/she
>> would bond two nic ports.
>> Our 'conduit to switch chip' reflects the corresponding lag
>> configuration in the switch chip.
>> Same goes for bridging, routing, acls.
>
> So you implement bonding netlink api? Or you hook into bonding driver
> itselt? Can you show us the code?
We use the netlink API and libnl. In our current model, our switch chip 
driver listens to netlink notifications and programs the switch chip. 
The switch chip driver uses libnl caches and libnl netlink apis to 
reflect the kernel state to switch chip.

Thanks,
Roopa
