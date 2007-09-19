From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 dirver's firmware images
Date: Wed, 19 Sep 2007 14:00:42 -0700
Message-ID: <1190235642.9540.261.camel@dell>
References: <200709181823.26429.vda.linux@googlemail.com>
 <20070918.112337.74737433.davem@davemloft.net>
 <1190145951.9540.230.camel@dell>
 <200709190930.39882.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	"netdev" <netdev@vger.kernel.org>
To: "Denys Vlasenko" <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2146 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958AbXISUCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 16:02:47 -0400
In-Reply-To: <200709190930.39882.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-19 at 09:30 +0100, Denys Vlasenko wrote:
+       /* gzip header (1f,8b,08... 10 bytes total + possible asciz filename)
+        * is stripped, 32-bit unpacked size (LE) is prepended instead */
+       sz = *zbuf++;
+       sz = (sz << 8) + *zbuf++;
+       sz = (sz << 8) + *zbuf++;
+       sz = (sz << 8) + *zbuf++;

I don't have a problem with removing the gzip header.  It doesn't
contain very useful information other than a valid header for sanity
check.  But I don't think we need to arbitrarily add the unpacked size
in front of the gzipped data.  The driver knows the size (e.g. the size
of RAM on the chip) and should pass it to the call.  The driver should
also allocate the memory for the unpacked data instead of allocating the
memory inside the call and freeing it by the caller.  For example, the
driver may need to use pci_alloc_consistent() if the firmware is to be
DMA'ed to the chip.

Other than that, everything else looks fine.  Thanks.

