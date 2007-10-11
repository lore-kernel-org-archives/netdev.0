From: David Miller <davem@davemloft.net>
Subject: Re: Question on TSO maximum segment sizes.
Date: Thu, 11 Oct 2007 16:37:37 -0700 (PDT)
Message-ID: <20071011.163737.36654032.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC32903C4407B@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37202
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752911AbXJKXhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 19:37:34 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903C4407B@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Thu, 11 Oct 2007 16:27:14 -0700

> I'm having an issue with TSO right vs. hardware that can't take the
> maximum segment size sent from the stack.  I've been told that the
> maximum packet size that can be sent to the hardware today is 64k, but
> my hardware can only take 32k in certain modes per queue due to hardware
> limitations.  I have two questions regarding this: 1) where is this
> value set in the TCP code, and 2) Is this something that can be
> configured on the fly?  If the answer to 2 is no, I will try and put
> something together to allow this to happen.

The TCP code just builds the maximum possible for the underlying
protocol, be it ipv4 or ipv6.  It takes the underlying protocol
maximum packet length, subtracts the amount of header space it
knows will be used, and uses that.

You'll need to use GSO sw segmentation to split the TSO packets
which are too big for your HW to handle.
