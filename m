From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH 0/2] d80211, rt2x00: fixes
Date: Wed, 13 Dec 2006 22:28:15 +0100
Message-ID: <a32f33a40612131328i177600dfh7f6437f4b5ed1bb8@mail.gmail.com>
References: <20061213180032.241265000.midnight@suse.cz>
	 <20061213171205.GB26415@csclub.uwaterloo.ca>
	 <1166031523.4741.0.camel@localhost.localdomain>
	 <20061213205425.GC26415@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Dan Williams" <dcbw@redhat.com>, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:34740 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbWLMV2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 16:28:17 -0500
Received: by wr-out-0506.google.com with SMTP id i7so218866wra
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 13:28:17 -0800 (PST)
To: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
In-Reply-To: <20061213205425.GC26415@csclub.uwaterloo.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > How, by private ioctls?  That's just wrong; I believe you still need to
> > go through the 4-way handshake to get the right keying information even
> > if you use PSK, which means you still need the supplicant, right?
>
> All I did was add this to /etc/network/interfaces:
>
> iface wlan0 inet static
>         address 192.168.1.51
>         network 192.168.1.0
>         netmask 255.255.255.0
>         gateway 192.168.1.254
>         broadcast 192.168.1.255
>         pre-up ifconfig wlan0 up
>         pre-up iwpriv wlan0 set AuthMode=WPAPSK
>         pre-up iwpriv wlan0 set EncrypType=TKIP
>         pre-up iwconfig wlan0 essid USR8054
>         pre-up iwpriv wlan0 set WPAPSK="My WPA passphrase..."

That is definately the rt2500 legacy driver and _not_ the rt2x00 driver.

> It seems to work, although I guess I could be wrong.  It was what I
> found in the documentation for the rt2x00 driver for doing WPA.  It
> looks nothing like the wpa_supplicant stuff I used to have with an older
> version of the driver.  My understanding was that the rt2x00 driver
> and/or d80211 stack took care of it now.

Correct, that is why those iwpriv commands are the clear evidence
you are not using rt2x00 but rt2500 legacy. Check which driver is loaded
rt2500 means legacy
rt2500pci means rt2x00.

Ivo
