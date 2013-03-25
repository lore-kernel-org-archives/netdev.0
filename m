From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH 6/6] xen-netback: don't disconnect frontend when seeing
 oversize frame
Date: Mon, 25 Mar 2013 11:47:17 +0000
Message-ID: <51503945.6040204@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com> <1364209702-12437-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:4092 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756025Ab3CYLrU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 07:47:20 -0400
In-Reply-To: <1364209702-12437-7-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/13 11:08, Wei Liu wrote:
> Some buggy frontends may generate frames larger than 64 KiB. We should
> aggresively consume all slots and drop the packet instead of disconnecting the
> frontend.

The following is the changeset description I wrote internally.  It's a
bit more descriptive.

Apologies for not sending out a proper patch in the first place.

"Some frontend drivers are sending packets >= 64 KiB in length.  This
length overflows the length field in the first frag making the
following frags have an invalid length ("Frag is bigger than frame").

Turn this error back into a non-fatal error by dropping the packet.
To avoid having the following frags having fatal errors, consume all
frags in the packet.

This does not reopen the security hole as if the packet as an invalid
number of frags it will still hit this fatal error case."

David
