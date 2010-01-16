From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] improve netem reorder flexibility
Date: Sat, 16 Jan 2010 01:46:54 -0800 (PST)
Message-ID: <20100116.014654.69913255.davem@davemloft.net>
References: <200912181901.28542.christian.samsel@rwth-aachen.de>
	<20091218.195907.189689401.davem@davemloft.net>
	<20091221095407.5430a630@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christian.samsel@rwth-aachen.de, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39448
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752314Ab0APJqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 04:46:45 -0500
In-Reply-To: <20091221095407.5430a630@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Dec 2009 09:54:07 -0800

> The netem logic for parsing attributes is different from others for
> historical reasons.  Looking at parse_attr():
> 
> If qopt is larger than expected, then the extra data is interpreted as
> the following nested attribute.
> 
> If qopt is smaller than expected, then it returns -EINVAL.

This is a really dangerous way to handle this.

This means if you grow qopt, older kernels think that the
extended area is attributes.

This also means that if you have new tools and send a qopt +
attributes, older kernels won't find the start of the attributes
correctly.  It will miss the attributes entirely.

This is a complete mess, and we need to sort it out before we think
about changing the size of qopt at this point.
