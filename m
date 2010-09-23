From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH v4 0/2] Get and Set Feature Reports on HIDRAW (USB and   Bluetooth)
Date: Thu, 23 Sep 2010 19:40:02 -0400
Message-ID: <4C9BE552.6080404@signal11.us>
References: <1281442367.12579.206.camel@localhost.localdomain> <1281990059-3562-1-git-send-email-alan@signal11.us> <20100923162521.GA15641@null>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Ville Tervo <ville.tervo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100923162521.GA15641@null>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/23/2010 12:25 PM, Ville Tervo wrote:
> Hi Alan,
>
> On Mon, Aug 16, 2010 at 10:20:57PM +0200, ext Alan Ott wrote:
>    
>> This is version 4. Built against 2.6.35+ revision 320b2b8de12698 .
>>      
>
> I gave a try to to this patch using your test tool [1] and very old BT
> keyboard. I don't have anything else ATM to test with. Is there some BT hid
> devices which support setting and getting features?
>    

A keyboard is the only BT device I've used which has feature reports.

> Shouldn't HIDIOCSFEATURE's bt version have similar wait as HIDIOCGFEATURE to
> get report status back from the device? or is there even any status coming back
> in successful case? Sorry I'm a newbie with HID and trying to understand how
> this should work.
>
> Now it just returns num of send bytes even if the remote device returned some
> error. Which one is the expected behavior?
>    

I made it function the same as the existing hidp_output_raw_report(). 
Nothing in net/bluetooth/hidp/core.c is acked at all. I'm not sure of 
the reasons.

Jiri, Marcel, any ideas?

> Other problem is that Get report is getting now handshake from set report.
>
>
>    

Yeah, that makes sense. I hadn't considered the set_report failing. In 
that case, I guess it means we _must_ wait for an ack for sent packets.

Anyone else agree or disagree?

Alan.


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
