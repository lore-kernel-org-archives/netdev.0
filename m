From: "John Que" <qwejohn@gmail.com>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sun, 4 Jun 2006 21:22:00 +0300
Message-ID: <ada605fb0606041122w36ad8320wa0a5d8241c98644c@mail.gmail.com>
References: <44817083.508@gentoo.org> <200606040025.32275.oliver@neukum.org>
	 <ada605fb0606040929p7a6ea69aw9488a75d611b23e5@mail.gmail.com>
	 <200606041917.55496.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Daniel Drake" <dsd@gentoo.org>,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, "Ulrich Kunitz" <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:44501 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750888AbWFDSWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 14:22:01 -0400
Received: by wr-out-0506.google.com with SMTP id 69so1248070wri
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2006 11:22:00 -0700 (PDT)
To: "Oliver Neukum" <oliver@neukum.org>
In-Reply-To: <200606041917.55496.oliver@neukum.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Oliver,

    I am sorry, but I think I don't understand ,
You said:
>A USB driver never will request an irq. Interrupt handling is done in
> the core usb layer. Individual drivers have no business there.

but in the zd1211 driver (not the rewrite version) I found this
call to request an irq:
request_irq(dev->irq, &zd1205_intr, SA_SHIRQ, dev->name, dev)

Also when looking in the linux tree, I see some request_irq() calls in USB
drivers, for exmaple in some drivers under usb/gadgaets, and more.

Can you please elaborate a bit ? What do you mean by saying
"A USB driver never will request an irq"?

-- John

On 6/4/06, Oliver Neukum <oliver@neukum.org> wrote:
> Am Sonntag, 4. Juni 2006 18:29 schrieb John Que:
> > I had noticed that the zd1211 driver does call request_irq() in zd1205_open(),
> > file zd1205.c; grepping for request_irq() in the rewrite driver yields
> > no results.
> > (I looked at the rewrite version from a week ago but in this point it
> > is probably the
> > same).
> > Why is this so ? I assume that the softmac layer does not call request_irq() on
> > behalf of the driver because this is not supposed to be like it, as I understand
> > its functionality. Can anybody briefly calrify this point ?
>
> A USB driver never will request an irq. Interrupt handling is done in
> the core usb layer. Individual drivers have no business there.
>
>         Regards
>                 Oliver
>
