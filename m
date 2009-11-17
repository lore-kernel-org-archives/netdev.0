From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [RFC] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 08:58:17 -0500
Message-ID: <20091117135817.GC27743@tuxdriver.com>
References: <1258465585.3682.7.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1258465585.3682.7.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 17, 2009 at 02:46:25PM +0100, Johannes Berg wrote:
> A number of people have tried to add a wireless interface
> (in managed mode) to a bridge and then complained that it
> doesn't work. It cannot work, however, because in 802.11
> networks all packets need to be acknowledged and as such
> need to be sent to the right address. Promiscuous doesn't
> help here. The wireless address format used for these
> links has only space for three addresses, the
>  * transmitter, which must be equal to the sender (origin)
>  * receiver (on the wireless medium), which is the AP in
>    the case of managed mode
>  * the recipient (destination), which is on the APs local
>    network segment
> 
> In an IBSS, it is similar, but the receiver and recipient
> must match and the third address is used as the BSSID.
> 
> To avoid such mistakes in the future, disallow adding a
> wireless interface to a bridge.
> 
> Felix has recently added a four-address mode to the AP
> and client side that can be used (after negotiating that
> it is possible, which must happen out-of-band by setting
> up both sides) for bridging, so allow that case.
> 
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

ACK -- we get these complaints fairly often...

I don't think I've sent the 4addr stuff to Dave yet.  Should I just
take this through my tree?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
