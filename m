From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] RDMA/cxgb3: logical-/bit-or confusion?
Date: Wed, 18 Feb 2009 16:37:51 -0800
Message-ID: <adazlgjz2g0.fsf@cisco.com>
References: <499BD470.4080705@gmail.com> <499C0143.1080703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: swise@opengridcomputing.com,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:32742 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbZBSAhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 19:37:52 -0500
In-Reply-To: <499C0143.1080703@gmail.com> (Roel Kluin's message of "Wed, 18
	Feb 2009 13:38:27 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > -	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) | crc_enabled ? 1 : 0;
 > +	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) || crc_enabled ? 1 : 0;

 > -	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) | crc_enabled ? 1 : 0;
 > +	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) || crc_enabled ? 1 : 0;

So as I said before, I guess this change is fine, except:

add/remove: 0/0 grow/shrink: 1/0 up/down: 18/0 (18)
function                                     old     new   delta
rx_data                                     1237    1255     +18

ie it makes the object code 18 bytes bigger on x86-64 (gcc 4.3.2).
Given that the code works the same either way, is this change a net win?

 - R.
