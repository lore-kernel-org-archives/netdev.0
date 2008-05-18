From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Sun, 18 May 2008 09:36:35 -0400
Message-ID: <1211117795.686.15.camel@localhost.localdomain>
References: <1211026337.3827.25.camel@johannes.berg>
	 <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org>
	 (sfid-20080517_154639_384202_6D3479C2)  <1211032475.6252.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1211032475.6252.2.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2008-05-17 at 15:54 +0200, Johannes Berg wrote:
> On Sat, 2008-05-17 at 15:45 +0200, Marcel Holtmann wrote:
> > Hi Johannes,
> > 
> > > The /sys/class/net/*/wireless/ direcory is, as far as I know, not
> > > used by anyone. Additionally, the same data is available via wext
> > > ioctls. Hence the sysfs files are pretty much useless. This patch
> > > makes them optional and schedules them for removal.
> > 
> > it is used by HAL to classify WiFi network cards as net.80211 instead  
> > of net.80203 and so we do have an actual user. However HAL only tests  
> > for the existence of the directory wireless/.
> 
> Oh, ok, I didn't know that, thanks.
> 
> > Please fix HAL first before submitting such a patch.
> 
> Sure, I'll take a look at that.

Instead of testing for wireless/, best thing would probably be to call
SIOCGIWRANGE on the device and if it returns EOPNOTSUP then it's not
wireless.  Some drivers may have to load firmware to figure out
supported rates and encryption capabilities, but to be honest, NM does
this to detect wireless devices and I haven't run into any issues in 4
years using it.  If there are issues with drivers, then we need to fix
the driver too.

dan

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
