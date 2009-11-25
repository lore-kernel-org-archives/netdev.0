From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14688] New: alignment of rx_skb in r8169
 driver
Date: Wed, 25 Nov 2009 13:55:07 -0800
Message-ID: <20091125135507.2160a534.akpm@linux-foundation.org>
References: <bug-14688-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: meyer@fsr.tu-darmstadt.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54978 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932983AbZKYVzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 16:55:18 -0500
In-Reply-To: <bug-14688-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 25 Nov 2009 15:01:16 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14688
> 
>            Summary: alignment of rx_skb in r8169 driver
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.29
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: meyer@fsr.tu-darmstadt.de
>         Regression: No
> 
> 
> Created an attachment (id=23933)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=23933)
> patch for rtl8169_alloc_rx_skb
> 
> Dear Maintainers,
> 
> I think there is a bug in the rtl8169_alloc_rx_skb function of the RealTek
> 8169/8168/8101 ethernet driver in kernel version 2.6.29.6, but also in current
> 2.6.31 versions.
> 
> For the case the align argument is different from 0, the skb_reserve call is
> expected to align the data field accordingly by padding. The number of bytes to
> reserve is calculated by the expression
> 
>             (align - 1) & (unsigned long)skb->data
> 
> which is wrong. I would suggest the following correction:
> 
> pad = align ? align - ((align - 1) & (unsigned long)skb->data) : NET_IP_ALIGN;
> if (pad == align) pad = 0; // optional
> skb_reserve(skb, pad);
> 
> A patch for r8169.c is provided as attachment.
> 

Thanks, but..

- please always submit patches via email, not via bugzilla. 
  Documentation/SubmittingPatches goes into some detail.

- prepare patches as a unified diff, in `patch -p1' form.  It should
  look like:

--- a/drivers/net/r8169.c~a
+++ a/drivers/net/r8169.c
@@ -207,7 +207,9 @@ enum rtl_registers {
 	ChipCmd		= 0x37,
 	TxPoll		= 0x38,
 	IntrMask	= 0x3c,
+wibble
 	IntrStatus	= 0x3e,
+wobble
 	TxConfig	= 0x40,
 	RxConfig	= 0x44,
 	RxMissed	= 0x4c,
_


- Please cc at least the following on the patch:

	Francois Romieu <romieu@fr.zoreil.com>
	"David S. Miller" <davem@davemloft.net>
	netdev@vger.kernel.org

- Don't forget the changelog and a Singed-off-by:!
