From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] netlink: don't send NETLINK_URELEASE for unbound
 sockets
Date: Sun, 10 Apr 2016 23:33:13 -0400 (EDT)
Message-ID: <20160410.233313.1103755950436664749.davem@davemloft.net>
References: <1460014298-30293-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dmitrijs.ivanovs-NO1NBkfNQUg@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1460014298-30293-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Thu,  7 Apr 2016 09:31:38 +0200

> From: Dmitry Ivanov <dmitrijs.ivanovs-NO1NBkfNQUg@public.gmane.org>
> 
> All existing users of NETLINK_URELEASE use it to clean up resources that
> were previously allocated to a socket via some command. As a result, no
> users require getting this notification for unbound sockets.
> 
> Sending it for unbound sockets, however, is a problem because any user
> (including unprivileged users) can create a socket that uses the same ID
> as an existing socket. Binding this new socket will fail, but if the
> NETLINK_URELEASE notification is generated for such sockets, the users
> thereof will be tricked into thinking the socket that they allocated the
> resources for is closed.
> 
> In the nl80211 case, this will cause destruction of virtual interfaces
> that still belong to an existing hostapd process; this is the case that
> Dmitry noticed. In the NFC case, it will cause a poll abort. In the case
> of netlink log/queue it will cause them to stop reporting events, as if
> NFULNL_CFG_CMD_UNBIND/NFQNL_CFG_CMD_UNBIND had been called.
> 
> Fix this problem by checking that the socket is bound before generating
> the NETLINK_URELEASE notification.
> 
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Dmitry Ivanov <dima-NO1NBkfNQUg@public.gmane.org>
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Applied and queued up for -stable, thanks everyone.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
