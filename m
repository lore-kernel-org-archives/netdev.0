From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Tue, 02 Jun 2015 06:41:23 -0700
Message-ID: <556DB283.8080300@roeck-us.net>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com> <556D522E.90607@roeck-us.net> <CAE4R7bChwW1awn8V6k7bF13v15_kPF0ui3NvyV2WkqN0XuTUqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel@savoirfairelinux.com, Chris Healy <cphealy@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39632 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759110AbbFBNlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 09:41:31 -0400
In-Reply-To: <CAE4R7bChwW1awn8V6k7bF13v15_kPF0ui3NvyV2WkqN0XuTUqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2015 12:44 AM, Scott Feldman wrote:
> On Mon, Jun 1, 2015 at 11:50 PM, Guenter Roeck <linux@roeck-us.net> wrote:
>
> [cut]
>
>> I brought this up before. No idea if my e-mail got lost or what happened.
>>
>> We use a fid per port, and a fid per bridge group. With VLANs, this is
>> completely
>> ignored, ahd there is only a single fid per vlan for the entire switch.
>>
>> Either per-port fids are unnecessary as well, or something is wrong here,
>> or I am missing something. Can you explain why we only need a single fid
>> per vlan, even if we have multiple bridge groups and the same vlan is
>> configured in all of them ?
>
> That brings up an interesting point about having multiple bridges with
> the same vlan configured.  I struggled with that problem with rocker
> also and I don't have an answer other than "don't do that".  Or,
> better put, if you have multiple bridge on the same vlan, just use one
> bridge for that vlan.  Otherwise, I don't know how at the device level
> to partition the vlan between the bridges.  Maybe that's what Vivien
> is facing also?  I can see how this works for software-only bridges,
> because they should be isolated from each other and independent.  But
> when offloading to a device which sees VLAN XXX global across the
> entire switch, I don't see how we can preserve the bridge boundaries.
>

One solution would be to use separate fids, like we do for non-vlan
bridges. That makes fid management more complex, sure, but it would work.
Otherwise we might have to explicitly disable support for more than one
bridge group on a switch, which seems a bit artificial to me.

Also, we already have cases where the switch is connected to the CPU with
more than one Ethernet port. It is easy to imagine that the user of such
a system might want to configure two bridge groups.

Thanks,
Guenter
