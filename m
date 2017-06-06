From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Tue, 6 Jun 2017 11:34:59 -0700
Message-ID: <20170606183457.fg7vgv2zji3fhlb5@ast-mbp.dhcp.thefacebook.com>
References: <AM4PR0501MB194008AAABEB6AAAA2ADFC82DBCB0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170606161709.GA8671@obsidianresearch.com>
 <20170606174233.w377ctwtapzccsk7@ast-mbp.dhcp.thefacebook.com>
 <20170606.134726.416045938000214127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgunthorpe@obsidianresearch.com, ilant@mellanox.com,
        saeedm@dev.mellanox.co.il, dledford@redhat.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        jsorensen@fb.com, andy.shevchenko@gmail.com,
        linux-fpga@vger.kernel.org, atull@opensource.altera.com,
        yi1.li@linux.intel.com, borisp@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35488 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751239AbdFFSfD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 14:35:03 -0400
Content-Disposition: inline
In-Reply-To: <20170606.134726.416045938000214127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 06, 2017 at 01:47:26PM -0400, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Tue, 6 Jun 2017 10:42:35 -0700
> 
> > so it's like rdma, but without using kernel rdma stack?
> 
> No sockets here, just transformation rules.  It's like offloading
> a complex TC rule to hardware version of that transformation.
> 
> Yes, there is state, but I argue that it is no different than TC
> offloading rules.  What if TC had "hash" and "crypt" operations
> and we attached them to appropriate u32 matches?  You wouldn't
> be able to tell the difference.

there is huge difference in underlying hw.
fpga is a separate device with its own phy and mac layers, its
own queues, packet parsing and rdma logic.
Where as tc offload is happening within the same hw queues/memory/stats
management logic. My understanding that when I do 'ethtool -L' to
change number of queues or 'ethtool -G' it changes the memory layout
that tc offload is operating on as well.
When I do 'ethtool -S' it shows me the stats for the device
that tc offload rules are integral part of.
Whereas fpga is a different physical device with its own
buffers and such. We can add 'ethtool -G_fpga, -L_fpga', etc
but this type of discussion needs to happen _before_ the whole
thing is merged. It will never happen after the fact.
Just look at mlx responses, they still don't acknowledge the issue
and instead pushing for ipsec, tls (in other words: new features)
instead of addressing production issues that are obviously
not glamorous to work on and fix.

> I think you are way over-obsessed with this FPGA offload thing,
> quite frankly.

if we didn't have issues with eswitch that drops packets and
we don't even know how many, I wouldn't be complaining.
There is a discussion going on to add few counters for
eswitch visibility, but it's taking forever and it's not at
the point of exposing eswitch as a kernel object.
Why? because it's hard to refactor it now into something like devlink
or whatever new abstraction that would be needed.
