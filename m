From: Daniel Mack <zonque-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: A reliable kernel panic (3.6.2) and system crash when visiting
 a particular website
Date: Sun, 21 Oct 2012 23:00:20 +0200
Message-ID: <50846264.302@gmail.com>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05> <20121020162759.GA12551@liondog.tnic> <966148591.30347.1350754909449.JavaMail.mail@webmail08> <20121020203227.GC555@elf.ucw.cz> <20121020225849.GA8976@liondog.tnic> <1781795634.31179.1350774917965.JavaMail.mail@webmail04> <20121021002424.GA16247@liondog.tnic> <1798605268.19162.1350784641831.JavaMail.mail@webmail17> <20121021110851.GA6504@liondog.tnic> <121566322.100103.1350820776893.JavaMail.mail@webmail20> <20121021170315.GB20642@liondog.tnic> <1906833625.122006.1350848941352.JavaMail.mail@webmail16> <5084530B.6030209@gmail.com> <1651404200.40745.1350852195790.JavaMail.mail@webmail04>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org
To: "Artem S. Tashkinov" <t.artem-DVq+YeWbj7cAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1651404200.40745.1350852195790.JavaMail.mail@webmail04>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 21.10.2012 22:43, Artem S. Tashkinov wrote:
>> Nice. Could you do that again with the patch applied I sent yo some
>> hours ago?
> 
> That patch was of no help - the system has crashed and I couldn't spot relevant
> messages.
> 
> I've no idea what it means.

The sequence of driver callbacks issued on a stream start is

 .open()
 .hw_params()
 .prepare()
 .trigger()

If the ALSA part really causes this issue, the bad things happen either
in any of the driver callback functions or in the core underneath.

The patch I sent returns an error from the hw_params callback, and as
you still see the problem, that means that the crash happens before any
of the USB audio streaming really starts.

Could you try and return -EINVAL from snd_usb_capture_open() please?

If anyone has a better idea on how to debug this, please chime in.


Daniel

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
