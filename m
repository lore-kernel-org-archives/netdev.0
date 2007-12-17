From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] endianness annotations and fixes for olympic
Date: Mon, 17 Dec 2007 18:15:50 -0500
Message-ID: <47670326.3010108@pobox.com>
References: <20071216205336.GW8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mikep@linuxtr.net, netdev@vger.kernel.org, kaaker@brocade.com
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50636 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756406AbXLQXQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 18:16:04 -0500
In-Reply-To: <20071216205336.GW8181@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro wrote:
> 	* missing braces in !readl(...) & ...
> 	* trivial endianness annotations
> 	* in olympic_arb_cmd() the loop collecting fragments of
> packet is b0rken on big-endian - we have
> 	(next_ptr && (buf_ptr=olympic_priv->olympic_lap + ntohs(next_ptr)))
> as condition and it should have swab16(), not ntohs() - it's host-endian
> byteswapped, not big-endian.  So if we get more than one fragment on big-endian
> host, we get screwed.
> 	This ntohs() got missed back when the rest of those had been switched
> to swab16() in 2.4.0-test2-pre1 - at a guess, nobody had hit fragmented
> packets during the testing of PPC fixes.
> 
> PS: Ken Aaker cc'd on assumption that he is the same guy who'd done the
> original set of PPC fixes in olympic
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

applied #upstream


