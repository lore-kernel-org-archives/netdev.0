From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 12:30:28 +0100
Message-ID: <4B5ED254.7010104@trash.net>
References: <87k4v5nuej.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87k4v5nuej.fsf-ySPBbPOLdCfMApvqMRVM/A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kalle Valo wrote:
> Hello,
> 
> I have been trying to understand how applications should use network
> QoS. My interest have been mostly from wireless perspective,
> especially how to utilise WMM and U-APSD properly, but naturally this
> applicable to all networks.
> 
> I have done some research about this, but I haven't managed to get
> anywhere. For example, from my point of view DiffServ is just one big
> mess and I can't see how in practise it can help applications.
> 
> I wrote a small wiki page to sum up my findings:
> 
> http://wireless.kernel.org/en/developers/Documentation/qos
> 
> I would like to clear up all this by and I'm willing to write a
> document for application developers about network QoS. But I need help
> to understand what's the proper way to mark different QoS
> prioritities.
> 
> In the wiki page I have tried to come up with different possible
> solutions (copied below), but I'm sure there are even more ways.
> 
> Please comment. I would like to get some understanding about this.
> 
> 
> ----------------------------------------------------------------------
> Solution 1: SO_PRIORITY with values 0-7
> 
> Easy, applications need to just use setsockopt() and be done with it.
> It's unknown how widely supported values 0-7 are and the exact meaning
> of them, but at least they make sense (0 default, 1 lowest priority
> and 7 highest priority). The problem is that the priority is used only
> in the first link, rest of the route is not able to benefit from the
> classification.
> 
> Pros:
> 
>     * easy for applications
>     * works with both IPv4 and IPv6 
> 
> Cons:
> 
>     * only visible in in the first L2 link, not visible to upper
>       layers (IP)
>     * no well defined meaning for the priority values 
> 
> Solution 2: SO_PRIORITY with values 256-263

You can actually encode any class handle in SO_PRIORITY, all classful
qdiscs support classification based on this.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
