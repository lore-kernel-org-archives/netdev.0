From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: [Bugme-new] [Bug 14737] New: e1000e driver experiences large
	packet losses
Date: Mon, 7 Dec 2009 17:20:43 -0500
Message-ID: <81bfc67a0912071420w3efd9f06x24e18a9179f29ea7@mail.gmail.com>
References: <bug-14737-10286@http.bugzilla.kernel.org/>
	 <20091207131900.19c776ed.akpm@linux-foundation.org>
	 <alpine.WNT.2.00.0912071340480.2420@jbrandeb-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:64141 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934088AbZLGWU7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 17:20:59 -0500
Received: by gxk26 with SMTP id 26so4576295gxk.1
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2009 14:21:05 -0800 (PST)
In-Reply-To: <alpine.WNT.2.00.0912071340480.2420@jbrandeb-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2009 at 4:53 PM, Brandeburg, Jesse
<jesse.brandeburg@intel.com> wrote:
> thanks akpm, I've been watching this thread but now I will try to jum=
p in.
>
> Caleb, can you please summarize where we are today, you've done a lot=
 of
> testing and the thread has gone on a while.
>
> Kernels known to fail (after any length):
2.6.32 - 2.6.29.6 is the range I've tested 2.6.29 only seemed to have
10% packet loss with mtr as opposed to the later, higher 30-50% still
that's abnormal and shouldn't be happening. I haven't tested farther
back yet.

> Kernels known to work:

flawlessly, none at this point. I've been able to replicate on every
version tested. given the fact it doesn't happen on every reboot and I
rarely reboot this makes it difficult to test. Other than the fact
that I've been unable to find a good kernel nothing suggests hardware
failure. given that some of the other e1000e bugs go back farther than
I've tested...

> Have you been able to try the latest e1000e from 2.6.32? =C2=A0it has=
 some
> fixes in it, although none right off the top of my head that will fix=
 your
> issue.

yes. reproducible. whether it occurs as often I'm not sure.

> I have a couple of related questions, why don't you have irqbalance
> enabled? =C2=A0Network interrupts should not be migrating across all =
cpus
> evenly, at the very least your system should be reconfigured to lock =
the
> interrupts to a particular core with smp_affinity.

is that new with 32? if not I don't know... I'm using arch linux's
config as a base, if it's something they should have enabled I can
relay the message.

> There is nothing in the ethtool -S statistics that I see that indicat=
es
> anything is wrong, you've gotten no tx timeouts as far as I can tell,=
 have
> you had any system panics (possibly seeming unrelated to network?)

no. My system seems perfectly stable (outside of some end user
software bugs, and even then only kopete seems to crash these days,
due to me using an experimental protocol). I'm unable to account for
the fact that tests aren't accounting for anything wrong...

hmm... thought... possibly iptables is dropping them as INVALID? I'm
still thinking that testing on just this system with one nic hooked
into the other might be a good idea, as the firewall configuration in
openwrt is not straightforward to me, this would also remove any QoS
rules that the router is applying, and random packets floating around
(that windows boxen are sending).
--=20
Caleb Cushing

http://xenoterracide.blogspot.com
