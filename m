From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: handing cloned frames to netif_rx()?
Date: Sat, 12 Jan 2008 00:48:52 +0200
Message-ID: <1ba2fa240801111448p7b2274ewd31becc56e57fc66@mail.gmail.com>
References: <1200014246.3861.148.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Ron Rindjunsky" <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1200014246.3861.148.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Jan 11, 2008 3:17 AM, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> In 802.11n, there is a case where multiple data frames are received
> aggregated into a single frame (A-MSDU).
>
> Currently, we copy each of these frames out into their own skb, but
> because of the alignment with that etc. I started to think that we could
> simply pass up a clone of the original skb with start/length adjusted
> properly so that it windows only the contained packet.
>
> The buffer would be shared but the data within the original window
> (starting with the 802.3 header) could even be written to, it won't be
> needed again by mac80211 once it's handed off to netif_rx(). The skb
> will obviously have lots of head- and tailroom but that space would be
> part of other packets.
>
> Is it ok to do this? Will something freak out if we pass a cloned skb to
> netif_rx()?
>
This would be great even in regular case. 4965 has ability to deliver
more frames per receiving buffer
Because of A-MSDU we keeps 8K receiving buffers which are
underutilized when A-MSDU is not used.

> johannes
>
