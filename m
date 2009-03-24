From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out, resetting
 -> dead NIC
Date: Tue, 24 Mar 2009 01:35:46 +0100
Message-ID: <49C82AE2.3080206@birkenwald.de>
References: <bug-12877-10286@http.bugzilla.kernel.org/> <20090315143214.90c71fb7.akpm@linux-foundation.org> <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de> <20090319165842.GA10819@xw6200.broadcom.net> <20090322132121.GA7871@pest> <20090323181859.GA5473@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.svr02.mucip.net ([83.170.6.69]:50596 "EHLO
	mailout.mucip.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbZCXAfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 20:35:54 -0400
In-Reply-To: <20090323181859.GA5473@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.03.2009 19:18, Matt Carlson wrote:

Hello Matt,

>> Mar 22 04:06:46 svr02 kernel: [1392136.468921] PCI Memory Mapped IO Disabled!!!!
[...]
>> Mar 22 04:07:14 svr02 kernel: [1392164.768266] PCI Memory Mapped IO Disabled!!!!
>> at this point the "watchdog" kicked in and did rmmod/modprobe, so I
>> think the only thing you can read out of this debugging log is that
>> there was no kernel message right before MMIO got disabled and it takes
>> quite a while to fire the Tx timeout.
> So traffic on this box must be pretty light for the watchdog to fire off
> 30 seconds after the MMIO problem was detected, right?  Interesting.

Just to make sure I didn't confuse you, the "watchdog" I was talking 
about here is a shellscript like this, executed every minute

---
/bin/ping -q -c 5 <defaultgw> > /dev/null
RC=$?
if [ ${RC} -ne 0 ]; then
	rmmod tg3; sleep 5; modprobe tg3; sleep 5; ifup --force eth0
fi
---

at :46 MMIO was disabled, at :00 the cronjob started which took until 
:15 before detecting the network was dead and reloaded the modules

>> Mar 22 04:07:15 svr02 kernel: [1392165.540078] tg3 0000:03:04.1: PCI INT B disabled
>> Mar 22 04:07:16 svr02 kernel: [1392166.817125] tg3: tg3_abort_hw timed out for eth0, TX_MODE_ENABLE will not clear MAC_TX_MODE=ffffffff
>> Mar 22 04:07:18 svr02 kernel: [1392168.398844] tg3: eth0: No firmware running.
>> Mar 22 04:07:29 svr02 kernel: [1392179.793309] tg3: eth0: Link is down.
>> Mar 22 04:07:31 svr02 kernel: [1392181.896030] tg3 0000:03:04.0: PCI INT A disabled
>> Mar 22 04:07:33 svr02 kernel: [1392183.957132] tg3.c:v3.94 (August 14, 2008)
>> Mar 22 04:07:33 svr02 kernel: [1392184.020034] tg3 0000:03:04.0: enabling device (0000 ->  0002)
>> Mar 22 04:07:33 svr02 kernel: [1392184.086083] tg3 0000:03:04.0: PCI INT A ->  GSI 16 (level, low) ->  IRQ 16

The tg3 watchdog (tg3: eth0: transmit timed out, resetting) did not 
appear at all in this circle, so I guess the checkscript killed the 
module before.

Yes, the NIC is very lightly loaded, around 100kbps / 70pps in each 
direction with a few occasional spikes.

>> I'm now switching to eth1.
> O.K.  I eagerly await your results.

So far so good, but it has only been running ~36 hours, that's not 
really a stability spree yet :-)

I'll keep you updated.

Bernhard
