From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm:
 mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Fri, 3 Jun 2011 13:47:43 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B659@EXDCVYMBSTM006.EQ1STM.local>
References: <1306922913-17803-1-git-send-email-metze@samba.org>
 <201106031201.21933.oneukum@suse.de>
 <2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B620@EXDCVYMBSTM006.EQ1STM.local>
 <201106031250.28041.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org" <Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Stefan Metzmacher <metze-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201106031250.28041.oneukum-l3A5Bk7waGM@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Oliver Neukum [mailto:oneukum-l3A5Bk7waGM@public.gmane.org]
> Sent: Friday, June 03, 2011 12:50 PM
> 
> Well, but cdc-ether usually means that you can start up dhcp and use
> the
> interface as a network card. Can the same be done with cdc-ncm or do
> you always
> need to establish a connection through a secondary interface?
> 

Some solutions (also based on cdc_ether driver) present IP address assigned
by 3G network. Initially device carrier is OFF. As soon as 3G network PDP
context is established, device send notification 
USB_CDC_NOTIFY_NETWORK_CONNECTION and host driver set carrier ON.

In such a case the problem is the lack of control channel definition in both
CDC ECM and CDC NCM. In order for mobile device to setup 3G connection
some application from PC must setup PDP context. The usual way to do it via
modem by using AT commands. So, it might be CDC ACM or some proprietary
solution. 
As a result you have to have vendor specific solution to find "real" control
channel (/dev/ttyACMx or other) and setup connection.
The need to know interface name is needed if you want to set default
route to that interface. Do you want to do it while you have pc broadband 
connection at hand? Probably not. 
I've tried to run 3g modem with cdc_ncm on Ubuntu 8 and later without any
need to specify interface names, same for Fedora.

So connection manager has to know: control interface, vendor- 
specific (or ever product specific) AT command sequence and optionally 
network interface name.
To sort this out, someone need either to track VID/PID or get
information by other means, for example via AT channel by guessing the
right tty device name.

Anyway, all this discussion is user space application problems.
Solution would be different from vendor to vendor.

/alexey

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
