From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH v4 06/10] e1000e: Support for byte queue limits
Date: Tue, 29 Nov 2011 13:01:37 -0800
Message-ID: <20111129130137.000009ce@unknown>
References: <alpine.DEB.2.00.1111281819350.24413@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31311 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756694Ab1K2VBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 16:01:38 -0500
In-Reply-To: <alpine.DEB.2.00.1111281819350.24413@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Nov 2011 18:33:16 -0800
Tom Herbert <therbert@google.com> wrote:

> Changes to e1000e to use byte queue limits.

First:  thanks Tom for looking into e1000e with this work.

> @@ -1096,6 +1097,10 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
>  			if (cleaned) {
>  				total_tx_packets += buffer_info->segs;
>  				total_tx_bytes += buffer_info->bytecount;
> +				if (buffer_info->skb) {
> +					bytes_compl += buffer_info->skb->len;

whats wrong with using total_tx_bytes or buffer_info->bytecount?  it
contains the "bytes on the wire" value which will be slightly larger
than skb->len, but avoids warming the skb->len cacheline unnecessarily.

the rest of the patch to e1000e looks okay.
