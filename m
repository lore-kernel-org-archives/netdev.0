From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: please revert. Was: [for-next 4/6] net/mlx5: FPGA, Add basic
 support for Innova
Date: Thu, 25 May 2017 21:40:59 -0700
Message-ID: <20170526044057.qpk3stulth5tfxcx@ast-mbp>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
 <20170526035830.mrnmxosh262bwjcr@ast-mbp>
 <20170526.001327.1776674102154218120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33609 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035147AbdEZElE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 00:41:04 -0400
Content-Disposition: inline
In-Reply-To: <20170526.001327.1776674102154218120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 12:13:27AM -0400, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Thu, 25 May 2017 20:58:32 -0700
> 
> > Dave, please revert this Innova fpga stuff.
> > I think you pushed it by accident, since it was mixed with
> > other valid changes.
> > The discussion didn't conclude.
> > Myself and Jes are clearly against such changes.
> > It definitely needs more discussion and wider consensus.
> 
> Why don't you finish your discussion, then I can revert or leave it in
> there?

Not really. What you're saying is 'shut up. mellanox can do
whatever they like as long as it's hidden behind pcie id'.

> If someone puts an FPGA inside of a device, and it's still behind the
> PCI ID of the ethernet card, how they expose that thing is largely at
> the discression of the driver author.

So you're saying it's ok to program fpga through nic whereas larger
kernel community is trying to come up with a solution to represent
fpga as a proper device for the kernel.
I suspect there will be popcorn threads during the next merge window.

> So feel free to discuss things with them, but in the end unless I am
> convinced otherwise (and I'm currently not), what they are doing now
> is fine by me.

If you didn't merge it already it would be fair course of action,
but it's clearly not the case.

> I will also state that it can't be that every time Mellanox tries to
> add something significant to their driver everyone screams "oh my,
> this thing is so hard to maintain as it is, you can't add this feature
> _too_."

Maintaining is only small part of it. The key argument against it
that all these things fpga, eswitch, etc are _hidden_ behind the nic.
It already causes headaches in production, because kernel cannot see
them.

> Sorry, it's an important driver, it's big, it has a lot of features,
> and all those problems people talk about simply come with the
> territory.

It's not a driver feature. It's not a nic.
It's a different physical device that mlx choose to program via nic.
There is also 'bluefield' nic on the horizon.
>From host point of view it looks like the same cx5/6 nic,
but it has arm cpus on board. Are you going to allow programming
it via nic as part of mlx5 driver as well?
It's no different than fpga hiding behind the nic...

> Use a less featurefull device, which uses a driver with slower
> development and less changes, if these things truly bother you.

like google did. food for thought.
