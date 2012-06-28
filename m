From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.4.x regression: rtl8169: frequent resets
Date: Fri, 29 Jun 2012 00:23:25 +0200
Message-ID: <20120628222325.GA1579@electric-eye.fr.zoreil.com>
References: <87y5n7qup0.fsf@spindle.srvr.nix> <20120628193026.GA31627@electric-eye.fr.zoreil.com> <87fw9fp2e1.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fw9fp2e1.fsf@spindle.srvr.nix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nix <nix@esperi.org.uk> :
> Francois Romieu <romieu@fr.zoreil.com> :
> > Can you try and revert 036dafa28da1e2565a8529de2ae663c37b7a0060 ?
> 
> I can try, but there's been a *lot* of code motion since then, 'git
> revert' fails hilariously (trying to patch obviously the wrong places):
> I'll have to do it by hand.

There is a single line reject in rtl8169_start_xmit. Other than that it
should patch -p1 -R fine.

[...]
> I note that at some time (after the first reset?), my MTU either flipped
> back to 1500, from its initial jumbo default, or simply refused to go
> jumbo in the first place. I bring it up like so:
> 
> ip link set fastnet up multicast on txqueuelen 100 mtu 7200
> ip addr add local 192.168.16.20/24 broadcast 192.168.16.255 dev fastnet
> 
> but its MTU is now shown as 1500 :( so at some point either jumbo frames
> have stopped working or the reset is flipping them off.
[...]
> [    1.341389] r8169 0000:06:00.0: eth0: jumbo features [frames: 6128 bytes, tx checksumming: ko]

This chipset is not supposed to be pushed beyond 6128 bytes.

-- 
Ueimor
