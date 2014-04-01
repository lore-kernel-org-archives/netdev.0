From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of switch chip datapath
Date: Tue, 1 Apr 2014 12:13:00 -0700
Message-ID: <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
References: <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <533312A3.5070600@cumulusnetworks.com> <20140326180356.GK2869@minipsycho.orion>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
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
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48655 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbaDATVX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 15:21:23 -0400
In-Reply-To: <20140326180356.GK2869@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 26, 2014, at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:

> Wed, Mar 26, 2014 at 06:47:15PM CET, roopa@cumulusnetworks.com wrote:
>> On 3/26/14, 9:59 AM, Jiri Pirko wrote:
>>> Wed, Mar 26, 2014 at 05:54:17PM CET, roopa@cumulusnetworks.com wrote:
>>> So you implement bonding netlink api? Or you hook into bonding driver
>>> itselt? Can you show us the code?
>> We use the netlink API and libnl. In our current model, our switch
>> chip driver listens to netlink notifications and programs the switch
>> chip. The switch chip driver uses libnl caches and libnl netlink apis
>> to reflect the kernel state to switch chip.
> 
> 
> So when you configure for example bonding over 2 ports, you actually use
> bonding driver to do that. And you userspace app listens to
> notifications and programs the switch chip accordingly. Am I close?
> 
> How about data? Is this new "bonding" interface able to assign ip to is
> and send/receive packets.
> 
> I'm still not sure I understand your concept. Do you have some
> documentation for it available?

Actually Jiri this is the code you and I worked on recently to netlink-ify bonding/slave attributes and active/inactive notification.  You have it right, user uses normal ip link tools and bonding driver to create bond, set attributes, and enslave switch ports.  RTM_NEWLINK is used to program ASIC to offload LAG to HW.  RTM_NEWLINK msgs contains bond attributes (mode, etc) and slave list, as well as slave status.  This is enough information to program ASIC.  Once programmed, ASIC offloads the data plane traffic, and in the case of egress, handles the LAG hash distribution.  Only the LACP control plane traffic makes it to the bonding driver; data plane traffic does not make it to the bonding driver.

So, not trying to sound like a smart-ass, but the documentation is the bonding driver, specifically the netlink attributes/notifications.

-scott