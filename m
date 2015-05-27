From: David Miller <davem@davemloft.net>
Subject: Re: [ovs-dev] [PATCH net] openvswitch: disable LRO unless stated
 otherwise
Date: Wed, 27 May 2015 11:56:02 -0400 (EDT)
Message-ID: <20150527.115602.371758291208515839.davem@davemloft.net>
References: <CALnjE+o-rHrcrmbwb4n4Py5smH3M8oOS-EBCGF2Rc0-e_Y1rmQ@mail.gmail.com>
	<20150527105021.21879f6c@griffin>
	<20150527132414.GB2502@x240.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, pshelar@nicira.com, netdev@vger.kernel.org,
	jbenc@redhat.com
To: fbl@sysclose.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbbE0P4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 11:56:05 -0400
In-Reply-To: <20150527132414.GB2502@x240.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@sysclose.org>
Date: Wed, 27 May 2015 10:24:14 -0300

> On Wed, May 27, 2015 at 10:50:21AM +0200, Jiri Benc wrote:
>> On Tue, 26 May 2015 15:03:56 -0700, Pravin Shelar wrote:
>> > OVS interface for generic networking device operation looks odd. have
>> > you considered adding new device ioctl to do this?
>> 
>> New ioctls for networking configuration are generally not allowed. The
>> preferred way to configure networking is netlink. And as this is very
>> much ovs specific (all other users of dev_disable_lro such as bridging
>> want to do this unconditionally), ovs netlink is the correct place to
>> put this to.
> 
> Exactly. Team, Bonding, bridge, and when you enable forwarding on a
> networking device gets LRO automatically disabled in the kernel.
> 
> I suggest to always disable LRO in the kernel as the other examples
> do until there is a real need in OVS to benefit from LRO to implement
> such API change.

Agreed, just turn off LRO by default and don't add a new interface to
turn it back on until we actually need it.
