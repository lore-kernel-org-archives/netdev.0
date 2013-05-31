From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: Another try at getting pktgen to work with wifi.
Date: Fri, 31 May 2013 21:14:15 +0200
Message-ID: <1370027655.14117.17.camel@jlt4.sipsolutions.net>
References: <51A79E4A.7000609@candelatech.com>
	   <51A7B049.9090201@openwrt.org> <51A7BA63.4080403@candelatech.com>
	   <51A857BF.7070008@openwrt.org> <51A8DC1C.1040908@candelatech.com>
	   (sfid-20130531_192143_291284_FB196B0A) <1370021846.14117.13.camel@jlt4.sipsolutions.net>
	  <51A8E53E.8030101@candelatech.com>
	 <1370025698.14117.15.camel@jlt4.sipsolutions.net>
	 <51A8F141.5050804@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51A8F141.5050804-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-05-31 at 11:51 -0700, Ben Greear wrote:

> > What I'm saying though is that I don't see where skb->priority is even
> > _used_ in the wifi stack. I can see it getting set, but not used.
> 
> ieee80211_downgrade_queue
> wme_downgrade_ac // sort of
> ieee80211_select_queue_80211 // sort of...seems twiddling skb->priority is more of a by-product here.
> 
> cfg80211_classify8021d

None of this actually matters, it's all within the select_queue() call
so doesn't need to store it in the skb.

I found it though -- the only thing that ever looks at it is
ieee80211_set_qos_hdr() to set the QoS header TID, and presumably that's
what ath9k complains about (hwsim is happy to just push packets.)

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
