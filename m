From: Andi Kleen <ak@suse.de>
Subject: Re: 3c59x (was Route cache performance under stress)
Date: Tue, 10 Jun 2003 18:20:29 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610162029.GA8168@wotan.suse.de>
References: <20030610.085342.41654796.davem@redhat.com> <Pine.LNX.4.44.0306101801070.26879-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, hadi@shell.cyberus.ca,
	ralph+d@istop.com, xerox@foonet.net, sim@netnation.com,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0306101801070.26879-100000@kenzo.iwr.uni-heidelberg.de>
List-Id: netdev.vger.kernel.org

> 
> > but he is such a good maintainer that he doesn't want to change over the
> > MEM I/O accesses for fear of breaking something.
> 
> Given that the 3c59x driver supports several generations of cards most of 
> them being EOL-ed years ago, it's pretty hard to do such change. If a new 
> driver would be forked that serviced only the latest generations (Cyclone 
> = 905B and Tornado = 905C(X)), switching to MMIO would probably make sense 
> along with lots of others small changes (large MTU/VLAN, polling 
> descriptors, MII-only media selection etc.) and maybe have NAPI in the mix 
> as well...

Can't you just wrap it in a few macros and offer a config for those
who want the best performance and a runtime test for the others?
Then switch between PIO and mmio dynamically.

Even runtime test should be pretty painless these days, the CPU normally
can execute hundreds or even thousands of tests in the time it takes to 
wait for an mmio or even PIO.



> 
> > It's actually a simple change to make if someone wants to
> > spend a few cycles on it,
> 
> Not if you include testing in those cycles :-)

Just make it a whitelist + a force module param.

 
-Andi (who has a 3c980 and could do it, but already has too much on his
todo list..) 
