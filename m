From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Sun, 4 Jun 2006 12:14:45 +0200
Message-ID: <200606041214.45999.stefan@loplof.de>
References: <200605251716.00742.IvDoorn@gmail.com> <200606031045.08763.stefan@loplof.de> <200606041002.33696.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from natipslore.rzone.de ([81.169.145.179]:50859 "EHLO
	natipslore.rzone.de") by vger.kernel.org with ESMTP id S932186AbWFDKN2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 06:13:28 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200606041002.33696.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag 04 Juni 2006 10:02 schrieb Ivo van Doorn:

> Except for the bluetooth radio key (which should be supported by the
> radiobtn interface as well) the other buttons have support through already
> excisting input devices if I am correct.

You are wrong for quite a bunch of laptop models. That's why I pointed you to 
the wistron_btns driver. Alternatively, look at the acerhk driver 
(http://www2.informatik.hu-berlin.de/~tauber/acerhk/). Many systems have a 
number of additional buttons that need to be handled by a special driver, all 
sent to userspace, and just one of them to trigger the wireless card. Other 
models just handle the button in ACPI and generate an additional ACPI event.

Looking at the RT2400-driver, I see what you want to accomplish: Take the view 
of the WLAN card on the hardware controlled button enable/disable and 
generate events on it. However, in many cases it is another driver (see 
above) that sets or clears this state, and this should be the instance to 
send the input event.

Note that I do not have objections against the driver being included in the 
kernel - it just does not qualify as generic radiobutton support, but I know 
it's hard to find a good name ;-)

Looking at the code only: There should be an additional non-polling interface 
for drivers that can generate events on the own.

Stefan
