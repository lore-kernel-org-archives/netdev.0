From: Zhang Rui <rui.zhang@intel.com>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 19 Jun 2007 11:32:44 +0800
Message-ID: <1182223964.5411.76.camel@localhost.localdomain>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org
To: hadi@cyberus.ca
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1182178882.4063.11.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-18 at 11:01 -0400, jamal wrote:
> On Fri, 2007-15-06 at 09:01 +0800, Zhang Rui wrote:
> 
> > > I dont have much time to look at your code given travel, but did you
> > > try to use your group id instead of the controller's?
> > > i.e:
> > > rtnl_open_byproto(&rth, nl_mgrp(mydiscoveredacpiid), NETLINK_GENERIC)
> > > 
> > Yes. It doesn't work if I use my group id here.
> > In fact, I'm using rtnl_open_byproto(&rth, 1, NETLINK_GENERIC) now.
> > That's why I said that this demo receives all the broadcasted genetlink
> > messages.
> 
> Ok, by inspection (sorry, still dont have much time) - your kernel code
> is sending to group 1; i.e
> 
> genlmsg_multicast(skb, 0, 1, GFP_ATOMIC);
> 
> you need to change that to send to your assigned id, i.e:
> genlmsg_multicast(skb, 0, acpi_event_genl_family.id, GFP_ATOMIC);
> 
Oh, that's the problem.
Great, now it works happily. :).
Jamal, thanks for your help!

Best regards,
Rui
