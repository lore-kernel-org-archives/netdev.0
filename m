From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH 19/21] orinoco: reduce differences between PCI drivers,
 create orinoco_pci.h
Date: Fri, 07 Apr 2006 18:43:25 -0400
Message-ID: <1144449805.5618.19.camel@dv>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
	 <20060407081057.16107.82106.stgit@dv.roinet.com>
	 <20060407221041.GC15720@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
In-Reply-To: <20060407221041.GC15720-lmTtMILVy1jWQcoT9B9Ug5SCg42XY1Uw0E9HWUfgJXw@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

On Sat, 2006-04-08 at 00:10 +0200, Francois Romieu wrote:
> > +	spin_lock_irqsave(&priv->lock, flags);
> 
> Interruptions are enabled. No need to save/restore.

Agreed.  I have found a few other places where it's also true.  I'll fix
it.  Actually, I'm going to change the locking to accommodate some USB
devices, so changes will be more widespread.

> > +	netif_device_attach(dev);
> > +
> > +	priv->hw_unavailable--;
> > +
> > +	if (priv->open && (! priv->hw_unavailable)) {
> > +		err = __orinoco_up(dev);
> 
> I wonder if it would be enough to issue hermes_set_irqmask() later
> in __orinoco_up() to release this irq disabled section.

Maybe, but I prefer not to touch this code, since it's about to undergo
a much more radical rework.

-- 
Regards,
Pavel Roskin



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
