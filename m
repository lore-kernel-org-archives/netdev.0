From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 3/3] mac80211: support bpf monitor filter
Date: Wed, 12 Apr 2017 16:29:07 +0200
Message-ID: <1492007347.2855.12.camel@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
         <20170412110726.9689-3-johannes@sipsolutions.net>
         (sfid-20170412_130907_870638_0C9870E2)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170412110726.9689-3-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> (sfid-20170412_130907_870638_0C9870E2)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-12 at 13:07 +0200, Johannes Berg wrote:
> 
>  struct ieee80211_if_mntr {
>  	u32 flags;
> 
[...]
+	bool deliver;

That's ... broken for multi-queue RX. I haven't really found a good
other way to do it. The best way will likely be to copy the SKB the
first time it's needed, build the radiotap header, and then keep a
reference to it to be able to clone it later if it's needed again.

johannes
