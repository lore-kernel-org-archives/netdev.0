From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Tue, 6 Jul 2004 13:31:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706133146.7ed47c69@dell_ss3.pdx.osdl.net>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org>
	<20040629222751.392f0a82.davem@redhat.com>
	<20040630152750.2d01ca51@dell_ss3.pdx.osdl.net>
	<20040630153049.3ca25b76.davem@redhat.com>
	<20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
	<20040701140406.62dfbc2a.davem@redhat.com>
	<20040702013225.GA24707@conectiva.com.br>
	<20040706093503.GA8147@outpost.ds9a.nl>
	<20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net>
	<20040706185856.GN18841@lug-owl.de>
	<20040706131731.540dd5fd.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jan-Benedict Glaw <jbglaw@lug-owl.de>, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040706131731.540dd5fd.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 13:17:31 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Tue, 6 Jul 2004 20:58:56 +0200
> Jan-Benedict Glaw <jbglaw@lug-owl.de> wrote:
> 
> > On Tue, 2004-07-06 11:47:41 -0700, Stephen Hemminger <shemminger@osdl.org>
> > wrote in message <20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net>:
> > 
> > > I propose that the following that will avoid sending window scaling that
> > > is big enough to break in these cases unless the tcp_rmem has been increased.
> > > It will keep default configuration from blowing in a corrupt world.
> > 
> > I'm not sure if this is the right way to react. I'd think it's okay to
> > give the user the possibility to scale the window so that it works with
> > his b0rk3d firewall, but default behavior should be to do whatever the
> > protocol dictates/allows.
> 
> I totally agree, and that's why the sysctl is there for people to
> tweak as they desire.
> 
> Jan, any particular reason you removed so much stuff (in particular
> netdev@oss.sgi.com) from the CC: list in your posting here?

The point is we are sending a bigger window scale then we need to.
The maximum receive window is limited by tcp_rmem[2], so we only need to
allow that much.  Having a different sysctl just for that is unnecessary and
potentially confusing.

The default tcp_rmem[2] is 174760, so we only need a wscale of 2 to represent
that. We were sending 7.
