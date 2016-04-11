From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Mon, 11 Apr 2016 20:19:04 +0200
Message-ID: <20160411181904.GB29709@lunn.ch>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
 <20160411022802.GB4307@lunn.ch>
 <570BE1C5.70502@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53304 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752590AbcDKSTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 14:19:09 -0400
Content-Disposition: inline
In-Reply-To: <570BE1C5.70502@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >The code you are deleting would of ignored the flags in the gpio
> >property, i.e. active low.
> 
>    Hm, you're right -- I forgot about that... :-/
> 
> >The new code in the previous patch does
> >however take the flags into account. Did you check if there are any
> >device trees which have flags, which were never used, but are now
> >going to be used and thus break...
> 
>    Checked this now and found out arch/arm/boot/dts/ar91-vinco.dts.
> Looks like it needs to be fixed indeed...

And this is where it gets tricky. You are breaking backwards
compatibility by now respecting the flag. An old DT blob is not going
to work.

You potentially need to add a new property and deprecate the old one.

    Andrew
