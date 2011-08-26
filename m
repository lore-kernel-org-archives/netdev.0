From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next ] Fix time-lag of IFF_RUNNING flag consistency
	between vlan and real devices
Date: Fri, 26 Aug 2011 16:45:53 +1000
Message-ID: <20110826064553.GA5874@gondor.apana.org.au>
References: <20110826060257.5304.62723.stgit@ltc219.sdl.hitachi.co.jp> <20110825230859.11b2b132@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?Q?Micha=C5=82Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43528 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1HZGqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 02:46:42 -0400
Content-Disposition: inline
In-Reply-To: <20110825230859.11b2b132@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2011 at 11:08:59PM -0700, Stephen Hemminger wrote:
>
> Just doing this for ioctl is not enough, API's other than user space depend on this.
> Also the user may have manually set different flags on vlan than on
> the real device.

Right, anything that tests netif_carrier_ok directly on the VLAN
device will still be delayed.

Now I remember discussing this issue in Japan.  However, I can't
recall the exact scenario in which the delay occured.

Is the issue with the link status going down on the real device,
or the real device coming up?

IIRC we already have mechanisms in place to ensure that down events
are not delayed by linkwatch.  Of course it is possible that this
isn't working for some reason, or some other part of the system is
causing the delay.

So please clarify the scenario for us Hayasaka-san.  Also please
let us know how you measured the delay.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
