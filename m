From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 17:36:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D0BD5B.201@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040616204248.GA23617@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> 	Seriously, these are my thoughts :
> 	o Backward/forward compatibility has always be my number one
> priority since 1996. There is many wireless drivers *NOT* in the
> kernel (see my web page) and many utilities using the current API. For
> example, both the Red-Hat configurator and the Debian installer link
> with libiw. So, it's not just about rewritting iwconfig.

This is something on which we'll have to agree to disagree.

In Linux we are free to improve the APIs :)


> 	I also asked Jeff why he want to redesign the API, and in the
> end there was only two issues :
> 	1) type-safe handler versus generic handler. I personally
> disagree with Jeff on that one. But, you can easilly fix it by
> offering wrapper to the current API :
> 	http://marc.theaimsgroup.com/?l=linux-netdev&m=107896289630224&w=2

I think I explained myself better, in the recent post in this thread. 
Such a wrapper does nothing to move the locking, ioctl marshalling, and 
security checks out of the drivers.

ethtool_ops and net/core/ethtool.c were quantum-leap improvements over 
the ethtool handling code that existed to that point.  Wireless needs to 
make the same quantum leap.


> 	2) The use of ioctls. I've created a patch to add RtNetlink
> support to the Wireless Extension API, and so far nobody has commented
> on this :
> 	http://marc.theaimsgroup.com/?l=linux-netdev&m=107846135617655&w=2
> 	A more recent/functional version of this patch is on my web
> page. I'm not going to waste time on this if nobody cares.

Well, I liked the patch at least :)

Take your patch, add new 'struct wireless_ops', convert existing 
wireless handlers, and we're good to go :)

	Jeff
