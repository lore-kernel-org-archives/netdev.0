From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 20:12:21 +0400
Message-ID: <20060428161221.GA12357@2ka.mipt.ru>
References: <54AD0F12E08D1541B826BE97C98F99F143B0E2@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51662 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030471AbWD1QN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 12:13:27 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
Content-Disposition: inline
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143B0E2@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 08:59:19AM -0700, Caitlin Bestler (caitlinb@broadcom.com) wrote:
> > Btw, how is it supposed to work without header split capabale
> > hardware?
> 
> Hardware that can classify packets is obviously capable of doing
> header data separation, but that does not mean that it has to do so.
> 
> If the host wants header data separation it's real value is that when
> packets arrive in order that fewer distinct copies are required to
> move the data to the user buffer (because separated data can
> be placed back-to-back in a data-only ring). But that's an optimization,
> it's not needed to make the idea worth doing, or even necessarily
> in the first implementation.

If there is dataflow, not flow of packets or flow of data with holes,
it could be possible to modify recv() to just return the right pointer,
so in theory userspace modifications would be minimal.
With copy in place it completely does not differ from current design
with copy_to_user() being used since memcpy() is just slightly faster
than copy*user().

-- 
	Evgeniy Polyakov
