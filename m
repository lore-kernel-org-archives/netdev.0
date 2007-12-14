From: Jouni Malinen <j@w1.fi>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Thu, 13 Dec 2007 21:08:08 -0800
Message-ID: <20071214050808.GE5698@jm.kir.nu>
References: <1197483844.6558.158.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1197483844.6558.158.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 12, 2007 at 07:24:04PM +0100, Johannes Berg wrote:

> This cleans up the frame receive handling. After this patch
>  * EAPOL frames addressed to us or the EAPOL group address are
>    always accepted regardless of whether they are encrypted or not
>  * other frames from a station are dropped if PAE is enabled and
>    the station is not authorized

Is there any way for an user space application to figure out whether a
received EAPOL frame was encrypted? In theory, WPA/WPA2 Authenticators
(e.g., hostapd) should verify that the frame was encrypted if pairwise
keys are set (whereas IEEE 802.1X Authenticator accepts unencrypted
EAPOL frames).

Did you/someone already verify that the Linux bridge code does not
bridge EAPOL frames? The use of a separate interface for this removed
the need for doing such filtering based on ethertype, but with EAPOL
frames using the same netdev with other data frames, the bridge code
should filter these out (mainly the PAE group addressed ones, but if I
remember correctly, IEEE 802.1X specified all frames using EAPOL
ethertype not to be bridged).

I haven't looked into the current implementations and/or proposed
patches on for TX part, but I would assume that it is possible to select
whether an EAPOL frame will be encrypted when injecting it(?).

-- 
Jouni Malinen                                            PGP id EFC895FA
