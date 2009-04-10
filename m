From: Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: usb_mon oops Re: tcpdump crashes 2.6.29.1 (and 2.6.29-rc5)
Date: Fri, 10 Apr 2009 00:24:35 -0600
Message-ID: <20090410002435.52794220.zaitcev@redhat.com>
References: <18906.49779.243047.207639@stoffel.org>
	<20090407120022.GA6519@ff.dom.local>
	<18907.28788.965069.573489@stoffel.org>
	<20090407130403.e0061a8d.zaitcev@redhat.com>
	<18908.42166.404232.721757@stoffel.org>
	<20090408232344.afed8103.zaitcev@redhat.com>
	<18910.46709.707557.135033@stoffel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <18910.46709.707557.135033-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Apr 2009 23:01:09 -0400, "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org> wrote:

> Any suggestions of a known good state I should start bisection from?

No suggestions, sorry. The part of usbmon that peeks at DMA-ed data
wasn't touched since December 2006. It worked fine since then,
your oops is the first. So, I don't expect bisection to help.
At best you're going to find the commit where uvcvideo was merged.

The right way forward is to deduce what's going on, IMHO. Maybe
usbmon is trying to take an address in the GART aperture and convert
it into a struct page. Or the direction in URB mismatches endpoint.
Or any number of other things.

I'm working on it, but I'm not done with puzzling out the dmesg
you sent me, sorry again.

-- Pete
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
