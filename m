From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: unlink URB when request timed out
Date: Wed, 12 Nov 2014 08:00:44 +0100
Message-ID: <1415775644.1761.1.camel@linux-0dmf.site>
References: <545FAE05.2030701@gmail.com>
	 <1415610506.16488.20.camel@linux-0dmf.site> <5462B1A3.9020401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mathy Vanhoef <vanhoefm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5462B1A3.9020401-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-11-11 at 20:02 -0500, Mathy Vanhoef wrote:
> On 11/10/2014 04:08 AM, Oliver Neukum wrote:

> > Which means that you are freeing memory that may still be used by DMA
> > at this time.
> > In addition you have no guarantee that the unlink is indeed finished
> > by the time the URB is reused.
> > If you wish to take this approach you better forget about this URB
> > and allocate a new one and free the buffer from the callback.
> 
> Hi Oliver,
> 
> Good catch. I think the DMA issue is also present in the current driver: it
> frees the buffer without unlinking/killing the URB at all. Can a malicious USB

Yes, it is present.

> device force a timeout to occur (i.e. delay the call to the completion
> handler)? If so this might be a use-after-free vulnerability.
> 
> It seems using usb_kill_urb instead of usb_unlink_urb in the patch prevents any
> possible use-after-free. Can someone double check?

usb_kill_urb() will do the job.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
