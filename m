From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH RFC] net/macb: Fix UDPv4 checksum offload
Date: Wed, 29 Apr 2015 11:15:21 +0100
Message-ID: <20150429111521.288902f6@lxorguk.ukuu.org.uk>
References: <1430174610-6834-1-git-send-email-jaeden.amero@ni.com>
	<20150427.224713.291017556251723132.davem@davemloft.net>
	<553FEF66.7010503@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nicolas.ferre@atmel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeff.westfahl@ni.com, mihai.neagu@ni.com
To: Jaeden Amero <jaeden.amero@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 251.110.2.81.in-addr.arpa ([81.2.110.251]:60566 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419AbbD2KPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 06:15:42 -0400
In-Reply-To: <553FEF66.7010503@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Unfortunately, the Cadence MACB doesn't support the enabling or
> disabling of checksum generation per descriptor.

So how does packet forwarding work ? If that means the device is
re-checksumming packets it is forwarding then that's really not very good
at all, especially if it takes frames that are unchecksummed and corrupts
them with a checksum midflight which is based upon unknown validity.

Other question: you seem to be assuming that the headers in part are
valid. That's not necessarily the case (even for local traffic you can
get UDP frames sent via RAW sockets that are invalid - eg with the ihl
pointing beyond the end of the packet). Given you then write into that
offset isn't a length check needed.

That might also be a useful fast path for longer frames, as you know the
worst case length for a 2 byte UDP frame.

Alan
