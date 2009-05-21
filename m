From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: rfkill vs. interface up
Date: Thu, 21 May 2009 11:39:49 -0400
Message-ID: <1242920389.14369.16.camel@localhost.localdomain>
References: <1242736331.4797.22.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1242736331.4797.22.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-05-19 at 14:32 +0200, Johannes Berg wrote:
> Hi,
> 
> More thoughts on rfkill ...
> 
> So we were thinking it would be sensible to just force interfaces down
> on rfkill, which is of course possible, and then reject attempts to set
> the interface UP while killed.
> 
> There's just one problem with that -- when you un-rfkill, does the
> kernel set interfaces UP again?
> 
> If not -- how would we possibly handle 'iwconfig .. txpower off'? We're
> mostly handling it like rfkill now afaict, but 'iwconfig .. txpower on'
> wouldn't be able to do anything properly.
> 
> If yes -- how do we know which interfaces to set UP? However we turn it,
> userspace can then not disable an interface regardless of rfkill state,
> which gets really confusing.
> 
> Therefore, I don't think we can simply set interfaces down on rfkill
> with the current scheme.
> 
> On the other hand, the interfaces really are dysfunctional in rfkill and
> we really need more integration.
> 
> 
> I'm happy to give up on 'iwconfig wlan0 txpower on/off' entirely, simply
> refuse supporting it (return -EINVAL if txpower.disabled) and then use
> the first scheme where rfkill forces the interface down but userspace is
> responsible for enabling it again. This is asymmetric, but I don't see
> what else to do.

That proposal sounds fine to me from a userspace perspective.  Sane
implementations don't assume the interface is IFF_UP when they configure
the device anyway (since it's not necessarily up at boot time or after
hibernate for example), and since you need a reconfigure after rfkill,
this seems reasonable.

You wouldn't have to give up on txpower either, you could simply map
'txpower off' to SW-rfkill, and 'txpower on' to un-SW-rfkill, where of
course the interface would be !IFF_UP after 'txpower on' just like
flipping the killswitch would.

Dan


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
