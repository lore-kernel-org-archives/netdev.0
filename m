From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 0/2] d80211, rt2x00: fixes
Date: Wed, 13 Dec 2006 15:54:25 -0500
Message-ID: <20061213205425.GC26415@csclub.uwaterloo.ca>
References: <20061213180032.241265000.midnight@suse.cz> <20061213171205.GB26415@csclub.uwaterloo.ca> <1166031523.4741.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:46416 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750862AbWLMUy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 15:54:26 -0500
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1166031523.4741.0.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 13, 2006 at 12:38:43PM -0500, Dan Williams wrote:
> How, by private ioctls?  That's just wrong; I believe you still need to
> go through the 4-way handshake to get the right keying information even
> if you use PSK, which means you still need the supplicant, right?

All I did was add this to /etc/network/interfaces:

iface wlan0 inet static
        address 192.168.1.51
        network 192.168.1.0
        netmask 255.255.255.0
        gateway 192.168.1.254
        broadcast 192.168.1.255
        pre-up ifconfig wlan0 up
        pre-up iwpriv wlan0 set AuthMode=WPAPSK
        pre-up iwpriv wlan0 set EncrypType=TKIP
        pre-up iwconfig wlan0 essid USR8054
        pre-up iwpriv wlan0 set WPAPSK="My WPA passphrase..."

It seems to work, although I guess I could be wrong.  It was what I
found in the documentation for the rt2x00 driver for doing WPA.  It
looks nothing like the wpa_supplicant stuff I used to have with an older
version of the driver.  My understanding was that the rt2x00 driver
and/or d80211 stack took care of it now.

--
Len Sorensen
