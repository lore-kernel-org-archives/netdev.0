From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: 3c59x (was Route cache performance under stress)
Date: Tue, 10 Jun 2003 18:15:07 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306101801070.26879-100000@kenzo.iwr.uni-heidelberg.de>
References: <20030610.085342.41654796.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@shell.cyberus.ca, <ralph+d@istop.com>, <xerox@foonet.net>,
   <sim@netnation.com>, <fw@deneb.enyo.de>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.085342.41654796.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, David S. Miller wrote:

> Acutally, the main issue with 3c59x is that it still
> uses PIO accesses. This basically makes it useless
> for routing or anything wanting serious latency.

I did try about 2 years ago and converted the driver to MMIO. I wasn't 
able to see _any_ kind of improvement and I was using it in parallel 
computation where latency counts. I have to say though that I wasn't 
interested at that time in obtaining profiles and such because only the 
end-user performance was important.

> Andrew Morton knows this,

... and knows about my MMIO trial too (mentioned also on vortex-list)...

> but he is such a good maintainer that he doesn't want to change over the
> MEM I/O accesses for fear of breaking something.

Given that the 3c59x driver supports several generations of cards most of 
them being EOL-ed years ago, it's pretty hard to do such change. If a new 
driver would be forked that serviced only the latest generations (Cyclone 
= 905B and Tornado = 905C(X)), switching to MMIO would probably make sense 
along with lots of others small changes (large MTU/VLAN, polling 
descriptors, MII-only media selection etc.) and maybe have NAPI in the mix 
as well...

> It's actually a simple change to make if someone wants to
> spend a few cycles on it,

Not if you include testing in those cycles :-)

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
