From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/4] [net-2.6.22] IrDA: IrLAP raw mode
Date: Sat, 7 Apr 2007 02:53:39 +0300
Message-ID: <20070406235339.GA4177@sortiz.org>
References: <20070317015729.GA3429@sortiz.org>
	<20070316.203451.102575913.davem@davemloft.net>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070316.203451.102575913.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 16, 2007 at 08:34:51PM -0700, David Miller wrote:
> From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
> Date: Sat, 17 Mar 2007 03:57:29 +0200
> 
> > This patch allows us to bypass the IrDA stack down to the IrLAP level.
> > Sending and receiving frames is done through a character device.
> > This is useful for e.g. doing real IrDA sniffing, testing external IrDA
> > stacks and for Lirc (once I will add the framing disabling switch).
> > 
> > Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
> 
> I understand the idea, but I fail to see any reason this should not be
> done with sockets.
> 
> Everywhere else we provide this kind of functionality it is either
> with netlink (nf_queue etc.) or raw sockets of some kind
> (AF_INET/SOCK_RAW, AF_PACKET, etc.)
> 
> Therefore IRDA should really provide this facility in some similar
> manner.
I definitely agree here. Actually, you can already sniff IrDA packets through
an AF_PACKET socket, that's what irdadump does. My patch was useless, forget
about it...

I have a question though: On top of the regular IrDA sniffing done with a
simple AF_PACKET socket, I also would like to be able to disable TX at the
IrLAP level (typically, this would allow an IrDA device to listen to all
the packets from an IrDA link without being noticed by the other devices).

I was thinking of adding a protocol private ioctl (as in SIOCPROTOPRIVATE) to
let userspace toggle an IrLAP flag (one per IrLAP instance) that would
disable a specific IrDA device TX path.
Would that be an acceptable solution, or would you rather see a netlink socket
for that purpose ?

Cheers,
Samuel.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
