From: Alan Cox <alan@linux.intel.com>
Subject: Re: Sending short raw packets using sendmsg() broke
Date: Fri, 26 Feb 2016 14:44:34 +0000
Message-ID: <1456497874.7064.7.camel@linux.intel.com>
References: <alpine.DEB.2.10.1602252105250.32432@jazz.he.fi>
	 <20160225.152628.1230785666614750970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: David Miller <davem@davemloft.net>, hessu@hes.iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:35234 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174AbcBZOol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 09:44:41 -0500
In-Reply-To: <20160225.152628.1230785666614750970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-25 at 15:26 -0500, David Miller wrote:
> From: Heikki Hannikainen <hessu@hes.iki.fi>
> Date: Thu, 25 Feb 2016 21:36:07 +0200 (EET)
> 
> > Commit 9c7077622dd9174 added a check, ll_header_truncated(), which
> > requires that a packet transmitted using sendmsg() with PF_PACKET,
> > SOCK_RAW must be longer than dev->hard_header_len.
> 
> Fixed by:
> 
> commit 880621c2605b82eb5af91a2c94223df6f5a3fb64
> Author: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
> Date:   Sun Nov 22 17:46:09 2015 +0100
> 
>     packet: Allow packets with only a header (but no payload)

The AX.25 case the header is variable length so this still doesn't fix
the regression as far as I can see.

Alan
