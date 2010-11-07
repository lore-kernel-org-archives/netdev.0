From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH] firewire: net: rate-limit log spam at transmit failure
Date: Sun, 07 Nov 2010 05:26:44 +0200
Message-ID: <1289100404.3277.28.camel@maxim-laptop>
References: <tkrat.01ca17fba0508ae0@s5r6.in-berlin.de>
	 <tkrat.1b9925fa1d199c23@s5r6.in-berlin.de>
	 <tkrat.18b9f67ac78dcbea@s5r6.in-berlin.de>
	 <tkrat.276aeae22ec60090@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47020 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab0KGD0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Nov 2010 23:26:49 -0400
Received: by fxm16 with SMTP id 16so3329636fxm.19
        for <netdev@vger.kernel.org>; Sat, 06 Nov 2010 20:26:48 -0700 (PDT)
In-Reply-To: <tkrat.276aeae22ec60090@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-11-07 at 00:23 +0100, Stefan Richter wrote:
> On  6 Nov, Stefan Richter wrote:
> > Then I tried an XIO2213A card in the AMD PC (again the Intel PC as peer)
> > and got 243 times "failed: 12" i.e. RCODE_BUSY and 81 times "failed: 10"
> > i.e. RCODE_SEND_ERROR during ftp transfer of a >500 MB large file from
> > XIO2213A to FW323.
> 

I also am getting strange results (but very good compared to what I had
recently).

With all your patches, I get very stable TCP and UDP streams from laptop
to desktop at 180~190 Mbits/s.

However, the opposite direction (desktop->laptop) still suffers from
tlabel exhaustion.
I added some printks, and I see, clearly that netif_stop_queue doesn't
always work (probably this is intended?).

If I replace == with >= in inc_queue_packets and similar in
dec_queued_packets, then tlabel exhaustion disappears, and I get ~240
Mbit/s on TCP and UDP.

UDP transfers work quite well, tested for few minutes.
TCP transfers unfortunelly trigger (probably a hardware) bug in notebook
OHCI controller (I have seen that meny times so far.)

Transfer just stops, and controller goes south.
If I unload the firewire-ohci, then when I load it:

[ 2062.632532] firewire_ohci 0000:07:00.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[ 2072.650173] firewire_ohci: Failed to reset ohci card.
[ 2072.650267] firewire_ohci 0000:07:00.0: PCI INT A disabled
[ 2072.650314] firewire_ohci: probe of 0000:07:00.0 failed with error -16


Only suspend to ram helps bring it back from that state.

Best regards,
	Maxim Levitsky

