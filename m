From: Krishna Chaitanya <chaitanya.mgit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Regression in 3.9 caused by "bridge: respect RFC2863 operational state"
Date: Thu, 2 May 2013 01:19:58 +0530
Message-ID: <CABPxzYLP53mnMXAicD33oX8TW77xnZziS=XBuVCy_u4H2oyLUw@mail.gmail.com>
References: <518166C5.4080904@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Sebastian Gottschall <s.gottschall-t37Kgv3TaIPQT0dZR+AlfA@public.gmane.org>
To: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <518166C5.4080904-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 2, 2013 at 12:32 AM, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org> wrote:
>
> In the long run, I'd like to sort out this mess by passing EAP frames to
> userspace via nl80211 - but since that will require userspace changes,
> what do we do about this issue in the mean time?

One quick solution i can think of is:

Temporarily we can make the interface UP as soon as
we are associated and then drop the data packets except for
EAPOL-KEY (ETH_H_PAE) frames in the mac80211.

ieee80211_frame_allowed has a rule to drops the unencrypted data frames
we just need to add a rule to drop encrypted data frames.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
