From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: changing usbnet's API to better deal with cdc-ncm
Date: Fri, 7 Sep 2012 15:10:40 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA574A0@EXDCVYMBSTM006.EQ1STM.local>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
	<2AC7D4AD8BA1C640B4C60C61C8E520154A6AA56BF9@EXDCVYMBSTM006.EQ1STM.local>
 <CACVXFVOmjvJQVWGzff_t7Hn7oAOxFzfV1CXyJWhuuBqjFcM3eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Oliver Neukum <oneukum@suse.de>, "bjorn@mork.no" <bjorn@mork.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:43668 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759366Ab2IGNdW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 09:33:22 -0400
In-Reply-To: <CACVXFVOmjvJQVWGzff_t7Hn7oAOxFzfV1CXyJWhuuBqjFcM3eQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ming Lei [mailto:tom.leiming@gmail.com]
> Sent: Friday, September 07, 2012 2:58 PM

> > Several issues need to be improved:
> > Tx path:
> > 1. IP packets must be accumulated in one NTB. Currently it's done via
> data copy.
> > Preferred way would be a possibility to have a list of skb-s in
> resulting frame sent down.
> 
> Looks the copy is inevitable because the buffer length of each skb in
> the list is not possible to be max endpoint packet aligned, so one
> short packet may terminate the current tx urb transfer.

Zero or short packet shall not be added if resulting NTB is max negotiated size.
It's yet another problem with usbnet, where we had to add some workarounds
to avoid redundant short/zero packets.

Regards,
Alexey
