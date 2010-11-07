From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH] firewire: net: rate-limit log spam at transmit failure
Date: Sun, 07 Nov 2010 05:32:17 +0200
Message-ID: <1289100737.3277.32.camel@maxim-laptop>
References: <tkrat.01ca17fba0508ae0@s5r6.in-berlin.de>
	 <tkrat.1b9925fa1d199c23@s5r6.in-berlin.de>
	 <tkrat.18b9f67ac78dcbea@s5r6.in-berlin.de>
	 <tkrat.276aeae22ec60090@s5r6.in-berlin.de>
	 <1289100404.3277.28.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Xqxp3qI6iIhSdygtVQFp"
Cc: linux1394-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49605 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183Ab0KGDcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Nov 2010 23:32:23 -0400
Received: by fxm16 with SMTP id 16so3330417fxm.19
        for <netdev@vger.kernel.org>; Sat, 06 Nov 2010 20:32:21 -0700 (PDT)
In-Reply-To: <1289100404.3277.28.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Xqxp3qI6iIhSdygtVQFp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Sun, 2010-11-07 at 05:26 +0200, Maxim Levitsky wrote:
> On Sun, 2010-11-07 at 00:23 +0100, Stefan Richter wrote:
> > On  6 Nov, Stefan Richter wrote:
> > > Then I tried an XIO2213A card in the AMD PC (again the Intel PC as peer)
> > > and got 243 times "failed: 12" i.e. RCODE_BUSY and 81 times "failed: 10"
> > > i.e. RCODE_SEND_ERROR during ftp transfer of a >500 MB large file from
> > > XIO2213A to FW323.
> > 
> 
> I also am getting strange results (but very good compared to what I had
> recently).
> 
> With all your patches, I get very stable TCP and UDP streams from laptop
> to desktop at 180~190 Mbits/s.
> 
> However, the opposite direction (desktop->laptop) still suffers from
> tlabel exhaustion.
> I added some printks, and I see, clearly that netif_stop_queue doesn't
> always work (probably this is intended?).
> 
> If I replace == with >= in inc_queue_packets and similar in
> dec_queued_packets, then tlabel exhaustion disappears, and I get ~240
> Mbit/s on TCP and UDP.
> 
> UDP transfers work quite well, tested for few minutes.
> TCP transfers unfortunelly trigger (probably a hardware) bug in notebook
> OHCI controller (I have seen that meny times so far.)
> 
> Transfer just stops, and controller goes south.
> If I unload the firewire-ohci, then when I load it:
> 
> [ 2062.632532] firewire_ohci 0000:07:00.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> [ 2072.650173] firewire_ohci: Failed to reset ohci card.
> [ 2072.650267] firewire_ohci 0000:07:00.0: PCI INT A disabled
> [ 2072.650314] firewire_ohci: probe of 0000:07:00.0 failed with error -16
> 
> 
> Only suspend to ram helps bring it back from that state.
> 
> Best regards,
> 	Maxim Levitsky
> 

To be clear, I use patches I attached on top of today mainline.
I have here my own hack to set the transaction timeout, because
update_split_timeout isn't called here at all, because nobody writes
to corresponding CSR registers.
Maybe I miss something though.

Best regards,
	Maxim Levitsky


--=-Xqxp3qI6iIhSdygtVQFp
Content-Type: application/x-bzip-compressed-tar; name="patches.tar.bz2"
Content-Disposition: attachment; filename="patches.tar.bz2"
Content-Transfer-Encoding: base64

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


--=-Xqxp3qI6iIhSdygtVQFp--

