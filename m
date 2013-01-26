From: Michael Leun <lkml20130126@newton.leun.net>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Sun, 27 Jan 2013 00:13:47 +0100
Message-ID: <20130127001347.584711b2@xenia>
References: <1358908337-13841-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, louis@asix.com.tw,
	davem@davemloft.net, Support@asix.com.tw
To: Freddy Xin <freddy@asix.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stator.leun.net ([85.214.203.199]:45817 "EHLO stator.leun.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754710Ab3AZXZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jan 2013 18:25:47 -0500
In-Reply-To: <1358908337-13841-1-git-send-email-freddy@asix.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Jan 2013 10:32:17 +0800
Freddy Xin <freddy@asix.com.tw> wrote:

> This is a resubmission.
> Fixed coding style errors.
[...]
> This patch adds a driver for ASIX's AX88179 family of USB 3.0/2.0
> to gigabit ethernet adapters. It's based on the AX88xxx driver but

I hope, there is some error/mistake on my side, otherwise I fear I
would have to say I find this driver to be total crap.

I tried it with an Digitus DN-3023 identifying itself as idVendor=0b95,
idProduct=1790 (some internet source claims it to be actually based on
asix reference design).

If I plug the device in the interface comes up with an mtu of 1488 -
this would be an very bad joke for any ethernet compliant device, even
more for an gigabit device where you clearly want to see at least a bit
of jumbo frames.

If I set the mtu to 1500 (the driver does not even complain when I set
the mtu to e.g. 2^31-1) and start to send bigger packets in some point
of time the device stops to work - means, after that you cannot even
send smaller packets, after some time you might get an kernel warning
"NETDEV WATCHDOG: eth3 (ax88179_178a): transmit queue 0 timed out" and
you have to unplug / replug the device to get it working again.

Note: With the W$ driver and exactly the same hardware you get at least
jumbo frames up to some 4000+X bytes - not great, but better than
nothing.

I would vote to not accept that driver for mainline as long as this
issues are not fixed. 

The vendor should not be able to claim "hooray, hooray, great device,
we even have an driver in linux main line" when it is actually such an
useless crap.

Of course I'm offering to help with any information or testing, but
unfortunately I do not have the knowhow to fix anything myself. 

-- 
MfG,

Michael Leun
