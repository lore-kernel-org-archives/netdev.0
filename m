From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] wireless, ipv4, ipv6: drop GTK-protected unicast IP
 packets
Date: Thu, 21 Nov 2013 06:24:27 -0800
Message-ID: <1385043867.10637.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385039154-20637-1-git-send-email-johannes@sipsolutions.net>
	 (sfid-20131121_140611_855342_F7C001E6) <1385039307.14273.4.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jouni Malinen <jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1385039307.14273.4.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-11-21 at 14:08 +0100, Johannes Berg wrote:
> On Thu, 2013-11-21 at 14:05 +0100, Johannes Berg wrote:
> 
> > @@ -498,7 +500,8 @@ struct sk_buff {
> >  	 * headers if needed
> >  	 */
> >  	__u8			encapsulation:1;
> > -	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
> > +	__u8			drop_unicast:1;
> 
> The obvious question is here, and for IPv4/IPv6 - should the wireless
> stack be responsible for doing this instead?

I don't really like the idea of reserving a bit for this in sk_buff,
and propagate it in every cloning ...

Someone should replace __copy_skb_header() by a single memset(),
because copying all these bits one by one is not really clever.

And then, adding a test in fast path (ip_rcv_finish()) is really not
nice.

I am not convinced this patch is the right way to solve the problem.



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
