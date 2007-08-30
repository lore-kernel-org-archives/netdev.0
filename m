From: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Subject: Re: oops with recent wireless-dev tree
Date: Thu, 30 Aug 2007 08:58:41 -0600
Message-ID: <20070830145840.GU14130@parisc-linux.org>
References: <20070829223752.GA6969@seehuhn.de> <1188475530.2963.20.camel@johannes.berg> <20070830074949.7cd25b04@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Jochen Voss <voss-52ZyvxujusuELgA04lAiVw@public.gmane.org>,
	linux wireless list <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bridge-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070830074949.7cd25b04-s08KbqtN0aBORcJjwVk88+YtYHrY8QCHmKZK+fsXvFM@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 07:49:49AM -0700, Stephen Hemminger wrote:
> > >     static int port_cost(struct net_device *dev)
> > >     {
> > > 	    if (dev->ethtool_ops->get_settings) {
> > >                                ^^^^
> > > 
> > > As far as I can figure out, dev->ethtool_ops is NULL and the crash
> > > happens while trying to derefernce ...->get_settings.
> 
> Devices aren't required to have ethtool_ops. The code there used to
> call ethtool directly, and it would handle the error cases. I'll rollup
> a fix this morning.

Yep, clearly my fault; that should read:

	if (dev->ethtool_ops && dev->ethtool_ops->get_settings) {

Since Stephen's already bagged fixing this, I shan't send a patch.
But if it includes something like the line above please add:

Acked-by: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
