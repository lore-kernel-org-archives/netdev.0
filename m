From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 19:06:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D0D265.3070804@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040616223316.GA29618@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> 	I think you did not understood my idea at all.
> 	If you build a set of generic wrappers and hook them in the
> iw_handler table, you could trivially add the features you feel are
> missing into those wrappers. Those wrappers would expose whatever API
> you choose to the driver, call your struct wireless_ops for example.

That doesn't help anything.  Wrappers add code, while not solving the 
following problems...

You want to expose a _specific_, fine-grained API to the driver.  That 
is by definition the smallest interface one can design for the low-level 
driver.  Anything else requires "additional work" -- from simple 
type-casting to real code.

The three major problems of the current WE iw_handler interface 
specifically are,

1) uses array, rather than a structure of function pointers.  This makes 
assignment of values _very_ easy to screw up.

2) type-opaque interfaces break C compiler pointer analysis.  This 
prevents alias optimization from working well, and also breaks checkers 
like the Stanford checker and sparse.  C gave the world a type system, 
we should use it.  :)

3) Uses and stores offsets to driver-private structures in generic code 
(iw_handler_def).  See #2 for pointer chasing/aliasing problems related 
to doing stuff like this.  Further, this is a massive layer / object 
lifetime violation.  The generic/core code should never need to know 
about a structure declared in a low-level driver.  That's backwards from 
the way information should flow.

It's not Jeff's weird personal preference that iw_handler be killed... 
type-opaque interfaces cause real problems.  A good C programmer should 
very, very rarely use type-casting.

	Jeff
