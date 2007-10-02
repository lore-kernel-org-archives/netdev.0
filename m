From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH][TG3]Some cleanups
Date: Mon, 01 Oct 2007 17:21:44 -0700
Message-ID: <1191284504.25892.129.camel@dell>
References: <1191175890.6165.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>,
	"netdev" <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1311 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628AbXJAXWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 19:22:54 -0400
In-Reply-To: <1191175890.6165.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-09-30 at 14:11 -0400, jamal wrote:
> Here are some non-batching related changes that i have in my batching
> tree. Like the e1000e, they make the xmit code more readable.
> I wouldnt mind if you take them over.
> 

Jamal, in tg3_enqueue_buggy(), we may have to call tg3_tso_bug() which
will recursively call tg3_start_xmit_dma_bug() after segmenting the TSO
packet into normal packets.  We need to restore the VLAN tag so that the
GSO code will create the chain of segmented SKBs with the proper VLAN
tag.

