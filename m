From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Re: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Thu, 15 Jan 2015 16:48:25 +0100
Message-ID: <3089325.gjrPpo2XX1@storm>
References: <1719052.SGOfRAJhfQ@storm> <8088599.PZmG8U31O2@storm> <1421335532.11734.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7Bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:55471 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbbAOPsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 10:48:32 -0500
In-Reply-To: <1421335532.11734.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 15. January 2015 07:25:32 Eric Dumazet wrote:
> On Thu, 2015-01-15 at 15:58 +0100, Thomas Jarosch wrote:
> > A colleague mentioned to me he saw the "Hardware Unit Hang" message
> > every
> > few days even running on kernel 3.4 (without your patch). Basically I'm
> > testing now if that's still the case with 3.19-rc4+ or not.
> > 
> > I'm all for fixing the root cause. I'm just interested if the e1000e
> > hang can even be triggered when using a max frag page size of 4096.
> > So far it transferred 751.6 GiB without a hiccup.
> 
> You told it was forwarding setup.
> 
> 1) What is the NIC receiving traffic.
> 2) What happens if you disable GRO on it ?

The setup is like this:

Win7 notebook (client)
    -> "private LAN" eth0 (e1000e)
        -> "external traffic" eth1 (r8169)

            -> local HTTP server in the intranet
               (2x e1000e using bonding)


Disabling gro on eth1 (r8169) seems to make eth0 (e1000e) stable.
As it usually hangs within seconds, it already transferred 28 GiB right now.

When I switch gro back on, it takes around three seconds until the hang.

Does that point into the right / any direction?

Thomas
