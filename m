From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] support for large number of network devices.
Date: Wed, 14 Jan 2004 01:13:03 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114071303.GG28521@waste.org>
References: <20040113154610.38f5934c.shemminger@osdl.org> <20040113155921.342db463.davem@redhat.com> <20040113161303.20f1159d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040113161303.20f1159d.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 13, 2004 at 04:13:03PM -0800, Stephen Hemminger wrote:
> On Tue, 13 Jan 2004 15:59:21 -0800
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > On Tue, 13 Jan 2004 15:46:10 -0800
> > Stephen Hemminger <shemminger@osdl.org> wrote:
> > 
> > > When using pseudo network devices, and really big machines; there is
> > > sometimes a need to have a lot of network devices.  This replaces the
> > > existing 2.6.1 limit of 100 entries an was O(n^2)
> > > with a algorithm that will handle up to 32768 entries with O(n) behaviour.
> > > 
> > > Does need a temporary page, but that shouldn't be a big deal.
> > > It has the same semantics, it will find the first empty name and use it.
> > 
> > I think your code has different semantics than exist currently.
> > 
> > For example, let's use the example of asking for "slip%d" then "eth%d".
> > The existing code would hand out "slip0" then "eth0", but your code would
> > deliver "slip0" then "eth1" which is not correct.
> > 
> > Or did I miss something clever in your algorithm?
> 
> 	It uses the output format string for the sscanf match, and since
> 	sscanf formats have to match. 	sscanf("eth0", "slip%d", &i) returns 0
> 	so eth0 would be skipped

Unfortunately sscanf("eth0-not-allocated", "eth%d", &i) fools it.
Which may or may not be worth worrying about.

-- 
 Matt Mackall : http://www.selenic.com : Linux development and consulting
