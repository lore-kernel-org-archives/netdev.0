From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [2.6.20-rt8] "Neighbour table overflow."
Date: Sun, 25 Mar 2007 18:37:00 -0700 (PDT)
Message-ID: <20070325.183700.118526082.davem@davemloft.net>
References: <Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
	<20070324.221034.45741983.davem@davemloft.net>
	<17927.7070.803210.600520@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org, samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <17927.7070.803210.600520-UYQwCShxghk5kJ7NmlRacFaTQe2KTcn/@public.gmane.org>
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

From: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date: Mon, 26 Mar 2007 11:02:22 +1000

> David Miller writes:
> 
> > The PPP generic layer seems to be very careful about it's handling of
> > the ->xmit_pending packet.
> 
> Mostly, but I think that this is a genuine leak.
> 
> > I'm really surprised this leak doesn't trigger already via the
> > ppp_synctty.c and ppp_async.c drivers, perhaps they do something to
> > make sure the transmitter gets purged properly when unregistering and
> > therefore ->xmit_pending does not get left non-NULL at unregister
> > time.
> 
> At least for ppp_async, I think what saves us is that pppd does a
> TCFLSH ioctl when shutting down the link, which calls
> ppp_async_flush_output, which calls ppp_output_wakeup.

Ok, that makes sense, I'll apply the leak fix for sure
especially since I even have your ACK now :-)

Thanks for reviewing Paul.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
