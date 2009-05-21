From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: rfkill vs. interface up
Date: Thu, 21 May 2009 12:32:07 -0400
Message-ID: <1242923527.14369.29.camel@localhost.localdomain>
References: <1242736331.4797.22.camel@johannes.local>
	 <1242920389.14369.16.camel@localhost.localdomain>
	 <1242921924.4212.11.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1242921924.4212.11.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-05-21 at 18:05 +0200, Johannes Berg wrote:
> On Thu, 2009-05-21 at 11:39 -0400, Dan Williams wrote:
> 
> > That proposal sounds fine to me from a userspace perspective.  Sane
> > implementations don't assume the interface is IFF_UP when they configure
> > the device anyway (since it's not necessarily up at boot time or after
> > hibernate for example), and since you need a reconfigure after rfkill,
> > this seems reasonable.
> > 
> > You wouldn't have to give up on txpower either, you could simply map
> > 'txpower off' to SW-rfkill, and 'txpower on' to un-SW-rfkill, where of
> > course the interface would be !IFF_UP after 'txpower on' just like
> > flipping the killswitch would.
> 
> Yeah, good point, that sounds better than having to give up on it -- the
> key though is that we can't recover IFF_UP state when that happens; if
> that's ok this should be fairly simple.

I don't think recovering IFF_UP needs to be done by the kernel.  rfkill
already hoses the card state anyway, requiring a full setup by
userspace, which usually includes ensuring the device is up (which, for
example, both NM and wpa_supplicant have done since the beginning of
time).

Dan

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
