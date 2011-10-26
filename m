From: Mark Lord <kernel@teksavvy.com>
Subject: asix usb network driver: nfg
Date: Wed, 26 Oct 2011 19:36:18 -0400
Message-ID: <4EA89972.5060101@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For the longest time, the asix driver was _the_ usb network device of choice.
But for kernels of the last year or two, it simply has not been working
reliably here with a variety of 10, 100, and 1000 mbit USB devices.

When it fails, one just sees it sitting there trying to do DHCP,
but it's outbound packets never arrive at the DHCP server.
It can listen just fine, though (wireshark), so I suspect some
sort of blockage in the transmit path.

With some devices, it sometimes works when unplugged (USB) and replugged,
but usually that doesn't help at all here.

And even when it does manage to transmit and negotiate DHCP,
a suspend/resume cycle is enough to kill it again.

Google reveals that this is also the case for at least a few others,
and some distro forums have been directing troubled users to download
the vendor's latest open source driver to get things working again.

     http://www.asix.com.tw/download.php?sub=searchresult&PItemID=84&download=driver

The driver there does indeed work better with some of my devices,
and oddly enough when I uncomment the "// #define DEBUG" line
it then works perfectly for me here.  Just like the old days,
except noisier in the syslog.  :)

Even suspend/resume work again.

So, the in-kernel asix driver seems badly broken for a lot of hardware,
and the vendor driver also has a slight race somewhere that is cured
by enabling debug logging.

Is there an asix driver maintainer, or anyone else with the time
to step up and try to fix these issues?

Thanks
Mark
