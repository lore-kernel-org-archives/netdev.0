From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 14:57:11 -0800
Message-ID: <20050107145711.367aa159@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501071650.56423.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501071650.56423.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 Jan 2005 16:50:51 -0600
"Jeremy M. Guthrie" <jeremy.guthrie@berbee.com> wrote:

> On Friday 07 January 2005 04:28 pm, Jesse Brandeburg wrote:
> > On Fri, 7 Jan 2005, Jeremy M. Guthrie wrote:
> > > I just updated the Intel Drivers to the latest on source-forge(5.6.10.1).
> > >  I now see lower CPU usage but I am still dropping.
> > >
> > > During a 60 second window the machine received 5,110,164 packets and
> > > dropped 20461 or roughly 0.4% packet loss.
> >
> > NAPI will cause a very busy stack to force the network card to drop the
> > data instead of the stack.  This is supposed to be a good thing because
> > the hardware will be forced to drop the packet (hopefully) instead of
> > interrupt rate thrashing your machine right when it needs the cpu to do
> > other stuff.  This is supposed to be the saving grace of NAPI.
> Makes sense.

Not sure if NAPI makes sense on transmit because it causes the transmit
ring to grow and freeing the transmit skb should be quick. Perhaps
other interrupt moderation schemes work better.

On receive the processing could take longer and NAPI is a real win.
