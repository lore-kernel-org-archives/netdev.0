From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: Re: [1/3] IRDA: Create new field tx_extra in skbuff
Date: Tue, 11 Nov 2008 02:00:01 +0100
Message-ID: <20081111010001.GB7511@sortiz.org>
References: <49185CBD.2040601@ceibo.fiec.espol.edu.ec>
	<20081110163546.GA19804@ioremap.net>
	<20081110165544.GB19804@ioremap.net>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081110165544.GB19804-i6C2adt8DTjR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 10, 2008 at 07:55:44PM +0300, Evgeniy Polyakov wrote:
> On Mon, Nov 10, 2008 at 07:35:46PM +0300, Evgeniy Polyakov (zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org) wrote:
> > What exactly should be carried in that area?
> 
> It is struct irda_skb_cb, which contains qos and other bits of
> intormation about how to transfer data, which are in turn obtained from
> various _cb IRDA structures, which I tracked upto to for example
> lsap_cb, which exists in the hash table. Do others also accessible via
> similar mechanism? Can that data be stored on per-device basis like
> ethernet checksum/offloading parameters (for example like LRO is done)?
I thought about that solution, but the irda_skb_cb line field has to be kept
per skb. It is needed for ircomm LMP flow control, in the skb destructor. I
see that BT rfcomm does something similar, but uses the skbuff->sk as a
rfcomm_dev pointer. As far as I understand the skbuff structure, that doesnt
look like a reasonnable solution, as we cant assume the sk pointer won't be
altered down the line.

Cheers,
Samuel.


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
