From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v3 1/2] iwlwifi: pcie: allow to build an A-MSDU using TSO
 core
Date: Wed, 21 Oct 2015 19:26:47 -0700
Message-ID: <1445480807.22974.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445452464-19525-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1445452464-19525-2-git-send-email-emmanuel.grumbach@intel.com>
	 <1445470211.22974.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8AB280@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Sharon, Sara" <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32E8AB280-Jy8z56yoSI9wl47ZQwxUxrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-10-22 at 00:14 +0000, Grumbach, Emmanuel wrote:

> 
> Well. I guess I should at least check, but even with very small MSS, our
> device supports up to 20 pointers for the same 802.11 packet: 2 are for
> metadata. So basically, so leaves me only 18 pointers. for each MSS I
> need at least 2 (one for the headers and one for the payload), so I will
> have at most 9 of these for one packet, even with a tiny MSS.
> 

I did not see in your patch where you made the checks about 18 segs in a
TSO packet ?

> I agree that all this should be added to the code in a comment.
> Speaking of which...
> int tso_count_descs(struct sk_buff *skb)
> {
>         /* The Marvell Way */
>         return skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags;
> }
> 
> What if there is some payload in the header?
> To me it sounds safer to return:
> 
> skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags + 1;
> 
> or maybe to test if there is some payload in the header and then add 1?
> If there is payload in the header, it should be considered as another
> frag, shouldn't it?

Minimal count is gso_segs (one per MSS)

Then you have to add extra for the cases we have a mss spanning a frag
in skb.

Thats a max of (skb_shinfo(skb)->nr_frags - 1) + (data_in_head() ? 1 :
0);

So I believe formula would be correct.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
