From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RTM_NEWLINK not received by application when connecting
 multiple devices simultaneously
Date: Thu, 19 Apr 2012 13:36:35 -0700
Message-ID: <20120419133635.7d816d67@nehalam.linuxnetplumber.net>
References: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
	<4F90208E.6070201@candelatech.com>
	<20120419075452.379f711b@s6510.linuxnetplumber.net>
	<CAKfDRXjCr0aDSDT8zN8A7_iNX6KAJwrR3NxaB8GAgz5oEiCB3w@mail.gmail.com>
	<CAKfDRXhAqFzPWAJkzhPdZGsUrtjex8uVwHBynCdvA+Zo6sjMig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54673 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932204Ab2DSUgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 16:36:38 -0400
In-Reply-To: <CAKfDRXhAqFzPWAJkzhPdZGsUrtjex8uVwHBynCdvA+Zo6sjMig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Apr 2012 21:54:24 +0200
Kristian Evensen <kristian.evensen@gmail.com> wrote:

> I spent some more time debugging this now. It turns out that which
> interface is seen by my application is not random, it is always the
> first one that is connected. This indicates that the bug is that the
> netlink message contains information about more than one interface.
> However, I am not able to prove this.

There is no filtering. A dump request always returns all interfaces.

> When I check for the presence of NLM_F_MULTI, it is always NULL. Also,
> the length of the received nlmsg (including payload) always equals the
> numbers of bytes I receive from the netlink socket, i.e., all the data
> is received.

The flags for nested and multi are relatively new. The original ancient
rtnetlink message formats dont use them, don't depend on them.
Since rtnetlink is cast in ABI concrete, it can't be fixed.

> Based on my understanding of netlink, an nlmsg will only contain one
> packet (for example ifinfomsg), unless the NLM_F_MULTI flag is set. Or
> am I mistaken?

The only reliable way is to parse the response to GET request is
to keep reading until you see NLMSG_DONE (or NLMSG_ERROR)

Look at example in libmnl source examples/rtnl/rtnl-link-dump.c
