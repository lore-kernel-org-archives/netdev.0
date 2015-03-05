From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH 4/5] TTY: fix tty_wait_until_sent on 64-bit machines
Date: Thu, 05 Mar 2015 09:31:19 -0500
Message-ID: <54F868B7.9010709@hurleysoftware.com>
References: <1425461947-15888-1-git-send-email-johan@kernel.org> <1425461947-15888-5-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby@suse.cz>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org,
	ZIV-Asier Llano Palacios <asier.llano@cgglobal.com>,
	stable <stable@vger.kernel.org>
To: Johan Hovold <johan@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1425461947-15888-5-git-send-email-johan@kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/04/2015 04:39 AM, Johan Hovold wrote:
> Fix overflow bug in tty_wait_until_sent on 64-bit machines, where an
> infinite timeout (0) would be passed to the underlying tty-driver's
> wait_until_sent-operation as a negative timeout (-1), causing it to
> return immediately.

Wow, that is a nasty bug.

> This manifests itself for example as tcdrain() returning immediately,
> drivers not honouring the drain flags when setting terminal attributes,
> or even dropped data on close as a requested infinite closing-wait
> timeout would be ignored.
> 
> The first symptom  was reported by Asier LLANO who noted that tcdrain()
> returned prematurely when using the ftdi_sio usb-serial driver.
> 
> Fix this by passing 0 rather than MAX_SCHEDULE_TIMEOUT (LONG_MAX) to the
> underlying tty driver.
> 
> Note that the serial-core wait_until_sent-implementation is not affected
> by this bug due to a lucky chance (comparison to an unsigned maximum
> timeout), and neither is the cyclades one that had an explicit check for
> negative timeouts, but all other tty drivers appear to be affected.

Reviewed-by: Peter Hurley <peter@hurleysoftware.com>
