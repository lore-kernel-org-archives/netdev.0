From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patch] caif: fix endian conversion in cffrml_transmit()
Date: Mon, 21 Nov 2011 06:33:56 +0000
Message-ID: <20111121063356.GH2203@ZenIV.linux.org.uk>
References: <20111121061722.GD7354@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:36703 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770Ab1KUGeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 01:34:03 -0500
Content-Disposition: inline
In-Reply-To: <20111121061722.GD7354@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2011 at 09:17:22AM +0300, Dan Carpenter wrote:
> The "tmp" variable here is used to store the result of cpu_to_le16()
> so it should be a u16 instead of an int.  We want the high bits set
> and the current code works on little endian systems but not on big
> endian systems.

Charming...  On b-e we end up feeding zeroes instead of the value we want.

However, that u16 clearly ought to be __le16 - it's there for purpose.
