From: Nix <nix@esperi.org.uk>
Subject: Re: [PATCH RFT net-next #2 0/6] via-rhine receive buffers rework
Date: Thu, 09 Apr 2015 19:08:04 +0100
Message-ID: <87r3rtjhtn.fsf@spindle.srvr.nix>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
	<87vbh6364u.fsf@spindle.srvr.nix>
	<20150408215051.GA25326@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:60294 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680AbbDISIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:08:21 -0400
In-Reply-To: <20150408215051.GA25326@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Wed, 8 Apr 2015 23:50:51 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 Apr 2015, Francois Romieu spake thusly:

> Nix <nix@esperi.org.uk> :
> [...]
>> I am sorry to report that I just had a watchdog-triggered autoreboot
>> during testing of this patch series :( with no log messages of any kind.
>> looks like the underlying bug is still there, or another bug with the
>> same symptoms (i.e. some way to crash inside the rx handler). I qwish I
>> could get some debugging output when this happens!
>
> You may add the patch below on top of the current stack. I don't expect
> much difference. Increasing RX_RING_SIZE could be a different story.

It still crashes with that patch. The lockups are definitely getting
rarer: I have to load the thing for several hours to see a single crash
now (though sometimes I am still (un)lucky and it dies almost at once).

> Did you keep netconsole disabled and did you increse via-rhine verbosity
> level ?

Oops! Netconsole *was* on: I've been using it for so long I'd forgotten
that you pretty much have to whap it with a hammer and turn it off in
.config to turn it off completely, not just stop mentioning it on the
kernel cmdline. It's off now.

The verbosity level is now 16, which should be enough to cover, well,
everything, and indeed I see extra log at initialization time:

[    0.911369] via_rhine: v1.10-LK1.5.1 2010-10-09 Written by Donald Becker
[    0.921653] via-rhine 0000:00:06.0 (unnamed net_device) (uninitialized): Reset succeeded
[    0.936067] via-rhine 0000:00:06.0 eth0: VIA Rhine III (Management Adapter) at 0xe0806000, 00:00:24:cb:c6:a0, IRQ 11
[    0.949911] via-rhine 0000:00:06.0 eth0: MII PHY found at address 1, status 0x786d advertising 05e1 Link cde1
[    0.969400] via-rhine 0000:00:07.0 (unnamed net_device) (uninitialized): Reset succeeded
[    0.983852] via-rhine 0000:00:07.0 eth1: VIA Rhine III (Management Adapter) at 0xe0808100, 00:00:24:cb:c6:a1, IRQ 5
[    0.997168] via-rhine 0000:00:07.0 eth1: MII PHY found at address 1, status 0x786d advertising 05e1 Link 41e1
[    1.006638] via-rhine 0000:00:08.0 (unnamed net_device) (uninitialized): Reset succeeded
[    1.021091] via-rhine 0000:00:08.0 eth2: VIA Rhine III (Management Adapter) at 0xe080a200, 00:00:24:cb:c6:a2, IRQ 9
[    1.034402] via-rhine 0000:00:08.0 eth2: MII PHY found at address 1, status 0x786d advertising 05e1 Link 41e1
[    1.043872] via-rhine 0000:00:09.0 (unnamed net_device) (uninitialized): Reset succeeded
[    1.058294] via-rhine 0000:00:09.0 eth3: VIA Rhine III (Management Adapter) at 0xe080c300, 00:00:24:cb:c6:a3, IRQ 12
[    1.062104] via-rhine 0000:00:09.0 eth3: MII PHY found at address 1, status 0x786d advertising 05e1 Link 4de1
[    1.071608] via-rhine 0000:01:00.0 (unnamed net_device) (uninitialized): Reset succeeded
[    1.086073] via-rhine 0000:01:00.0 eth4: VIA Rhine III (Management Adapter) at 0xe080e000, 00:00:24:d1:2a:3c, IRQ 10
[    1.099911] via-rhine 0000:01:00.0 eth4: MII PHY found at address 1, status 0x786d advertising 05e1 Link 41e1
[    1.119402] via-rhine 0000:01:01.0 (unnamed net_device) (uninitialized): Reset succeeded
[    1.133915] via-rhine 0000:01:01.0 eth5: VIA Rhine III (Management Adapter) at 0xe0810100, 00:00:24:d1:2a:3d, IRQ 7
[    1.147234] via-rhine 0000:01:01.0 eth5: MII PHY found at address 1, status 0x7849 advertising 05e1 Link 0000
[    1.156747] via-rhine 0000:01:02.0 (unnamed net_device) (uninitialized): Reset succeeded
[    1.171262] via-rhine 0000:01:02.0 eth6: VIA Rhine III (Management Adapter) at 0xe0812200, 00:00:24:d1:2a:3e, IRQ 10
[    1.185095] via-rhine 0000:01:02.0 eth6: MII PHY found at address 1, status 0x7849 advertising 05e1 Link 0000
[    1.194599] via-rhine 0000:01:03.0 (unnamed net_device) (uninitialized): Reset succeeded
[    1.209094] via-rhine 0000:01:03.0 eth7: VIA Rhine III (Management Adapter) at 0xe0814300, 00:00:24:d1:2a:3f, IRQ 7
[    1.212436] via-rhine 0000:01:03.0 eth7: MII PHY found at address 1, status 0x7849 advertising 05e1 Link 0000
[...]
[   17.264820] via-rhine 0000:00:06.0 gordianet: Reset succeeded
[   17.299978] via-rhine 0000:00:06.0 gordianet: link up, 100Mbps, full-duplex, lpa 0xCDE1
[   17.347962] via-rhine 0000:00:06.0 gordianet: force_media 0, carrier 1
[   18.221924] via-rhine 0000:00:09.0 wireless: Reset succeeded
[   18.256936] via-rhine 0000:00:09.0 wireless: link up, 100Mbps, full-duplex, lpa 0x4DE1
[   18.304399] via-rhine 0000:00:09.0 wireless: force_media 0, carrier 1
[   18.360046] via-rhine 0000:01:00.0 voip: Reset succeeded
[   18.397168] via-rhine 0000:01:00.0 voip: link up, 100Mbps, full-duplex, lpa 0x41E1
[   18.442578] via-rhine 0000:01:00.0 voip: force_media 0, carrier 1
[   18.510970] via-rhine 0000:00:07.0 adsl: Reset succeeded
[   18.546141] via-rhine 0000:00:07.0 adsl: link up, 100Mbps, full-duplex, lpa 0x41E1
[   18.591511] via-rhine 0000:00:07.0 adsl: force_media 0, carrier 1
[   18.639051] via-rhine 0000:00:08.0 bdsl: Reset succeeded
[   18.671983] via-rhine 0000:00:08.0 bdsl: link up, 100Mbps, full-duplex, lpa 0x41E1
[   18.717363] via-rhine 0000:00:08.0 bdsl: force_media 0, carrier 1

(again, the first two interfaces, gordianet and wireless, are the ones
being stressed by this test.)

Of course now I've done this it's not crashing! Maybe it's netconsole-
related on top of everything else, or I'm just being unlucky... I'll
keep trying.

-- 
NULL && (void)
