From: "Holger Hoffstaette" <holger@wizards.de>
Subject: Re: Reproducible data corruption with sendfile+vsftp - splice regression?
Date: Fri, 30 Nov 2007 10:20:26 +0100
Message-ID: <pan.2007.11.30.09.20.24.737500@wizards.de>
References: <pan.2007.11.29.23.42.52.661624@wizards.de> <474FC4D9.3020506@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762240AbXK3JVF@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Nov 2007 09:07:53 +0100, Eric Dumazet wrote:

> CC to netdev, it might concern network guys

It is indeed related to network/r8169, more below.

> Could you try with a test file containing unique patterns ?

Same result, here is new information.

- contrary to my first posting, the corruption does not reliably occur
when a second client pulls the file; sorry for that. The difference is
that the box that gets corrupted data only has a 100mbit interface, while
the one that gets working data is completely gigabit (all on the same
switch though).

- after some digging in my server changelogs I noticed that I had enabled
misc. r8169 offload options not too long ago (while migrating to gigabit
and perftesting the new network), and bingo! Turning off tso (leaving all
others on except for UDP which is apparently not implemented) singled out
the corruption while ftp'ing to the slower 100mbit client.

I have since just permanently disabled tso and everything is
fine with and without sendfile. So this seems to be either a bug with the
r8169 or some bad interaction of tso with sendfile, but then maybe it's
just the symptom of a race condition/timing problem. Is tso on the r8169
known to be kaput?

lspci says:

00:08.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 17
        I/O ports at d000 [size=256]
        Memory at f6022000 (32-bit, non-prefetchable) [size=256]
        [virtual] Expansion ROM at 60000000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2

Further suggestions welcome, looks like we're getting somewhere.
I can still create broken files with tso and the unique patterns that Eric
suggested, if that helps tracking down the tso corruption.

thank you!
Holger
