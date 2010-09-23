From: Ville Tervo <ville.tervo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 0/2] Get and Set Feature Reports on HIDRAW (USB and
 Bluetooth)
Date: Thu, 23 Sep 2010 19:25:21 +0300
Message-ID: <20100923162521.GA15641@null>
References: <1281442367.12579.206.camel@localhost.localdomain>
 <1281990059-3562-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Stefan Achatz <erazor_de-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Stephane Chatty <chatty-rXV5z7KbLFk@public.gmane.org>,
	Michael Poole <mdpoole-IZmAEv5cUt1AfugRpC6u6w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Bastien Nocera <hadess-0MeiytkfxGOsTnJN9+BGXg@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: ext Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1281990059-3562-1-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alan,

On Mon, Aug 16, 2010 at 10:20:57PM +0200, ext Alan Ott wrote:
> This is version 4. Built against 2.6.35+ revision 320b2b8de12698 .


I gave a try to to this patch using your test tool [1] and very old BT
keyboard. I don't have anything else ATM to test with. Is there some BT hid
devices which support setting and getting features?

Shouldn't HIDIOCSFEATURE's bt version have similar wait as HIDIOCGFEATURE to
get report status back from the device? or is there even any status coming back
in successful case? Sorry I'm a newbie with HID and trying to understand how
this should work.

Now it just returns num of send bytes even if the remote device returned some
error. Which one is the expected behavior?

Other problem is that Get report is getting now handshake from set report.


2010-09-23 17:55:46.680612 < ACL data: handle 38 flags 0x02 dlen 9
    L2CAP(d): cid 0x008b len 5 [psm 17]
      HIDP: Set report: Feature report
      0000: 09 ff ff ff                                       ....
2010-09-23 17:55:46.680653 < ACL data: handle 38 flags 0x02 dlen 6
    L2CAP(d): cid 0x008b len 2 [psm 17]
      HIDP: Get report: Feature report
      0000: 09                                                .
2010-09-23 17:55:46.697577 > HCI Event: Number of Completed Packets (0x13) plen 5
    handle 38 packets 1
2010-09-23 17:55:46.698579 > HCI Event: Number of Completed Packets (0x13) plen 5
    handle 38 packets 1
2010-09-23 17:55:46.776827 > ACL data: handle 38 flags 0x02 dlen 5
    L2CAP(d): cid 0x0040 len 1 [psm 17]
      HIDP: Handshake: Invalid parameter
2010-09-23 17:55:46.777069 < ACL data: handle 38 flags 0x02 dlen 7
    L2CAP(d): cid 0x008b len 3 [psm 17]
      HIDP: Data: Output report
      0000: 01 77                                             .w
2010-09-23 17:55:46.797577 > HCI Event: Number of Completed Packets (0x13) plen 5
    handle 38 packets 1
2010-09-23 17:55:46.816826 > ACL data: handle 38 flags 0x02 dlen 5
    L2CAP(d): cid 0x0040 len 1 [psm 17]
      HIDP: Handshake: Invalid parameter
2010-09-23 17:55:46.856828 > ACL data: handle 38 flags 0x02 dlen 5
    L2CAP(d): cid 0x0040 len 1 [psm 17]
      HIDP: Handshake: Unsupported request



[1] http://lkml.org/lkml/2010/6/17/414

-- 
Ville the HID newbie
