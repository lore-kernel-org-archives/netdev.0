From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: A race in register_netdevice()
Date: Tue, 3 May 2011 16:41:59 -0700
Message-ID: <20110503164159.6664fa48@nehalam>
References: <87y62ugg0a.fsf@purkki.adurom.net>
	<20110428165237.0c1eddbc@nehalam>
	<878vungyq4.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <878vungyq4.fsf-5ukZ45wKbUHoml4zekdYB16hYfS7NtTn@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 04 May 2011 02:18:11 +0300
Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org> wrote:

> Hi Stephen,
> 
> Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> writes:
> 
> > On Fri, 29 Apr 2011 01:36:37 +0300
> > Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org> wrote:
> >
> >> there seems to be a race in register_netdevice(), which is reported here:
> >> 
> >> https://bugzilla.kernel.org/show_bug.cgi?id=15606
> >> 
> >> This is visible at least with flimflam and ath6kl. Basically what
> >> happens is this:
> >> 
> >> Apr 29 00:21:35 roska flimflamd[2598]: src/udev.c:add_net_device() 
> >> Apr 29 00:21:35 roska flimflamd[2598]: connman_inet_ifname: SIOCGIFNAME(index
> >> 4): No such device
> >> Apr 29 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message() buf
> >> 0xbfefda3c len 1004
> >> Apr 29 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message()
> >> NEWLINK len 1004 type 16 flags 0x0000 seq 0
> 
> [...]
> 
> >> I have confirmed that both of these patches fix the issue. Now I'm
> >> wondering which one is the best way forward. Or is there a better way
> >> to fix this?
> >> 
> >
> > I see no problem with moving this.
> > SIOCGIFNAME should not need to hold rtnl.
> 
> I'm having difficulties of fixing the race and exploring other
> options. Is there any particular issue why SIOCGIFNAME should not take
> rtnl?

None really, but the answer given by SIOCGIFNAME is going to race
anyway. I.e if ioctl returns a value, by the time user space sees it
the result may have changed.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
