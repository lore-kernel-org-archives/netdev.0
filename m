From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: RE: [Xen-devel] xen-netfront sets partial checksum at wrong offset
Date: Mon, 11 May 2015 10:25:58 -0700 (PDT)
Message-ID: <3a08e270-3a70-417b-9ab8-439c7cdc1eb2@default>
References: <ee74926e-deb3-4cbc-9798-42c19f4fe219@default>
 <20150511150827.GA23561@l.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	david.vrabel@citrix.com, ian.campbell@citrix.com,
	wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42430 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbEKR0G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:26:06 -0400
In-Reply-To: <20150511150827.GA23561@l.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Please CC the maintainers of the driver. You can get that from
> 'scripts/get_maintainer.pl'
> 
> I've done that for you.

Thanks, Konrad.

I am copying Wei too who had fixed the below problem earlier.
It fixed the incorrect ip_hdr(). tcp_hdr() still needs to fixed.

commit d554f73df6bc35ac8f6a65e5560bf1d31dfebed9
Author: Wei Liu <wei.liu2@citrix.com>
Date:   Wed Feb 19 18:48:34 2014 +0000

    xen-netfront: reset skb network header before checksum

    In ed1f50c3a ("net: add skb_checksum_setup") we introduced some checksum
    functions in core driver. Subsequent change b5cf66cd1 ("xen-netfront:
    use new skb_checksum_setup function") made use of those functions to
    replace its own implementation.

    However with that change netfront is broken. It sees a lot of checksum
    error. That's because its own implementation of checksum function was a
    bit hacky (dereferencing skb->data directly) while the new function was
    implemented using ip_hdr(). The network header is not reset before skb
    is passed to the new function. When the new function tries to do its
    job, it's confused and reports error.

    The fix is simple, we need to reset network header before passing skb to
    checksum function. Netback is not affected as it already does the right
    thing.

    Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
    Signed-off-by: Wei Liu <wei.liu2@citrix.com>
    Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
    Cc: Paul Durrant <paul.durrant@citrix.com>
    Tested-By: Sander Eikelenboom <linux@eikelenboom.it>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks.

Venkat
