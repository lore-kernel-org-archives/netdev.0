From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] support for large number of network devices.
Date: Wed, 14 Jan 2004 13:51:57 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114195157.GJ28521@waste.org>
References: <20040113154610.38f5934c.shemminger@osdl.org> <20040113155921.342db463.davem@redhat.com> <20040113161303.20f1159d.shemminger@osdl.org> <20040114071303.GG28521@waste.org> <20040114113734.4e9a0865.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040114113734.4e9a0865.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 14, 2004 at 11:37:34AM -0800, Stephen Hemminger wrote:
> 
> > Unfortunately sscanf("eth0-not-allocated", "eth%d", &i) fools it.
> > Which may or may not be worth worrying about.
> 
> Hmmm,  the old code would have assigned "eth0" in that case, new code
> would assign "eth1".  Other difference is in the case of whitespace.
> scanf("white  space0", "white space%d", &i)
> because any whitespace matches multiple whitespace characters.
> 
> Is it worth making a separate explicit match routine?

I think it's probably easier to just add O(1) lookup and then do
explicit lookups on eth0..ethx. As Dave's pointed out, fast lookups
are wanted elsewhere. I made a quick hack to make the sscanf trick
work (try scanning for "eth%d%c" and insisting that %c not get parsed)
but it was not pretty.

-- 
Matt Mackall : http://www.selenic.com : Linux development and consulting
