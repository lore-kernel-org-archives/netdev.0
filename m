From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Tue, 6 Mar 2007 19:43:06 +0100
Message-ID: <200703061943.07350.mb@bu3sch.de>
References: <1173144447.15891.93.camel@johannes.berg> <20070306171316.GA19669@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070306171316.GA19669-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 March 2007 18:13, Jean Tourrilhes wrote:
> On Tue, Mar 06, 2007 at 02:27:26AM +0100, Johannes Berg wrote:
> > Hi,
> > 
> > Wtf! After struggling with some strange problems with zd1211rw (see some
> > other mail) I decided to think again about what could possibly cause all
> > the other problems I'm having with it. The kernel seems fine, but iw*
> > userspace continually segfaults! And it also seems to be not
> > reproducible for most other people, I'd asked on IRC once a while.
> > 
> > Well. Some thinking and stracing and thinking later it occurred to me...
> > Hell! wext is ioctls and includes this gem:
> > 
> > struct  iw_point
> > {
> >   void __user   *pointer;       /* Pointer to the data  (in user space) */
> >   __u16         length;         /* number of fields or size in bytes */
> >   __u16         flags;          /* Optional params */
> > };
> > 
> > Of course nobody ever tells you this, but it's used in a shitload of
> > places.
> 
> 	Yep, and it's even in fs/compat_ioctl.c. Hint, hint ;-)

Ok, it is wrapping the following ioctls:

HANDLE_IOCTL(SIOCGIWRANGE, do_wireless_ioctl)
HANDLE_IOCTL(SIOCSIWSPY, do_wireless_ioctl)
HANDLE_IOCTL(SIOCGIWSPY, do_wireless_ioctl)
HANDLE_IOCTL(SIOCSIWTHRSPY, do_wireless_ioctl)
HANDLE_IOCTL(SIOCGIWTHRSPY, do_wireless_ioctl)
HANDLE_IOCTL(SIOCGIWAPLIST, do_wireless_ioctl)
HANDLE_IOCTL(SIOCGIWSCAN, do_wireless_ioctl)
HANDLE_IOCTL(SIOCSIWESSID, do_wireless_ioctl)
HANDLE_IOCTL(SIOCGIWESSID, do_wireless_ioctl)
HANDLE_IOCTL(SIOCSIWNICKN, do_wireless_ioctl)
HANDLE_IOCTL(SIOCGIWNICKN, do_wireless_ioctl)
HANDLE_IOCTL(SIOCSIWENCODE, do_wireless_ioctl)
HANDLE_IOCTL(SIOCGIWENCODE, do_wireless_ioctl)

What about SIOCSIWSCAN, SIOCSIWENCODEEXT, SIOCGIWENCODEEXT
and some others that also use iw_point?

-- 
Greetings Michael.
