From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: AX88179_178A USB3 ethernet adapter performance issue
Date: Thu, 6 Feb 2014 15:39:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B9A21@AcuExch.aculab.com>
References: <CAMVG2ssoBwk56n-k5VB9yO2LP4wc+gTv4o_17r-WYakwE6h2uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: 'Daniel J Blueman' <daniel@quora.org>,
	Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	'Sarah Sharp' <sarah.a.sharp@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58652 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751794AbaBFPj7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 10:39:59 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26398-05 for <netdev@vger.kernel.org>;
 Thu,  6 Feb 2014 15:39:53 +0000 (GMT)
In-Reply-To: <CAMVG2ssoBwk56n-k5VB9yO2LP4wc+gTv4o_17r-WYakwE6h2uQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel J Blueman
> Hi Freddy et al,

I've copied this to linux-usb.

> I'm experiencing poor network performance using an ASIX AX88179_178A
> USB3 to ethernet adapter using any recent linux kernel (eg 3.11),
> using an Intel XHCI USB3 controller.

There a several problems with the xhci driver that show up when
trying to use the ax88179_178a driver.
Unfortunately some of the fixes have caused regressions on other
host controllers with disk transfers.
The patches may, or may not, be present in your kernel.
The 'scatter-gather' support that is used in order to enable TSO
is particularly good at exercising the buggy code paths.

> Running iperf tests between one host with a gigabit PCIe NIC, via a
> gigabit switch to the other host with various interfaces:
> 
> PCIe bcm957762: send 818Mb/s, recv 910Mb/s
> USB2 smsc75xx: send 341Mb/s, recv 330Mb/s
> USB3 ax88179_178a: send 347Mb/s, recv 18.7Mb/s
> 
> Are you able to reproduce the same 19Mb/s receive rate there?

It might be that you are only actually running at USB2 speeds
(check with lsusb -t).

I have seem line rate Ge from my ax88179 card, but only with a
patched kernel.

	David

> 
> Many thanks,
>   Daniel
> --
> Daniel J Blueman
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
