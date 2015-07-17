From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [RFC net-next 22/22] openvswitch: Use regular GRE net_device
 instead of vport
Date: Fri, 17 Jul 2015 10:10:50 -0700
Message-ID: <CALnjE+oW2Fwao-b_Dq_UGdS+1BPMRHthyrZxcnbzsxpk4VqB4w@mail.gmail.com>
References: <cover.1436537414.git.tgraf@suug.ch>
	<74f200a9e634a9fefd6de85265f54b8a6697ab72.1436537414.git.tgraf@suug.ch>
	<20150716085915.GA11294@penelope.isobedori.kobe.vergenet.net>
	<20150716145246.GC22603@pox.localdomain>
	<CALnjE+omzvWop3T2bD_Yp9gW3XN-9NbeEnCmh615iNqJH2dvog@mail.gmail.com>
	<20150717105853.GB18033@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>, rshearma@brocade.com,
	ebiederm <ebiederm@xmission.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	"Ji???? P??rko" <jiri@resnulli.us>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Justin Pettit <jpettit@nicira.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35902 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbbGQRKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 13:10:51 -0400
Received: by igbij6 with SMTP id ij6so41963480igb.1
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 10:10:50 -0700 (PDT)
In-Reply-To: <20150717105853.GB18033@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2015 at 3:58 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 07/16/15 at 02:36pm, Pravin Shelar wrote:
>> On Thu, Jul 16, 2015 at 7:52 AM, Thomas Graf <tgraf@suug.ch> wrote:
>> > I'm inclined to change this and use an in-kernel API as well to
>> > create the net_device just like VXLAN does in patch 21.
>> >
>> > Pravin, what do you think?
>>
>> About the vxlan APIs we also need to direct netlink interface for
>> userspace to configure vxlan device. This will allow us to remove
>> vxlan compat code from ovs vport-netdev.c in future.
>
> Do you mean creating the tunnel devices from user space? This would
> break existing users of the OVS Netlink interface. How do you want
> to prevent that?
To handle old interface there is compat code in netdev-vport in patch 22.

OVS userspace should be able to create any type of tunneling device
and then add it as netdev type vport. so that OVS has two types of
vport i.e. netdev and internal, rather than vport for each type of
tunnel.
This way we can keep compat code simple. All enhancements can be
directly done to new interface.
