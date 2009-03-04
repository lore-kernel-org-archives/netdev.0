From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cipso: subtraction on unsigned hdr_delta
Date: Tue, 03 Mar 2009 23:42:08 -0800 (PST)
Message-ID: <20090303.234208.199560892.davem@davemloft.net>
References: <49ADADEA.8090306@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751808AbZCDHmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 02:42:24 -0500
In-Reply-To: <49ADADEA.8090306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 03 Mar 2009 23:23:38 +0100

> hdr_delta is unsigned, so take care not to subtract below 0.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

I'd like Paul to look at this.

It looks like it does the wrong thing when the option space increases,
which would have made hdr_delta negative if it were of a signed type.

I think therefore that sk_conn->icsk_ext_hdr_len needs to be adjusted
in both directions, just just when the option area length shrinks.
