From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: 2nd revision of make xfrm_audit_log more generic
Date: Wed, 25 Jul 2007 17:17:23 -0700 (PDT)
Message-ID: <20070725.171723.45714101.davem@davemloft.net>
References: <200707251921.l6PJLhxV015256@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, sgrubb@redhat.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55440
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751675AbXGZARY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:17:24 -0400
In-Reply-To: <200707251921.l6PJLhxV015256@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Wed, 25 Jul 2007 14:21:43 -0500

> This is 2nd revision of patch to modify xfrm_audit_log() such
> that it can accomodate auditing other ipsec events
> besides add/delete of an SA or SPD entry.
> 
> 2nd revision includes new define for all IPsec
> events in audit.h and introduces "op=" entry
> in logfile as well as add a hyphen in description
> for report parsing. 
> 
> This is a small change to accomodate updating
> ipsec protocol to RFCs 4301, 4302 and 4303 which
> require auditing some ipsec events if auditing
> is available. Please let me know if ok.
> 
> Signed-off-by: Joy Latten <latten@austin.ibm.com>

I like very much how the implementation of xfrm_audit_log() got
simplified.

But _TEN_ function call arguments, good grief!

That's at least twice as many as most cpus can pass in registers.

Let's try an alternative where you have specialized
xfrm_audit_log_foo() routines that take a user policy pointer, or
whatever the main object is.

If internally this just unpacks the needed bits and calls some
do_xfrm_audit_log() thing inside of the auditing code that takes lots
of arguments, that's fine, but let's not expand all of that argument
setup code in the main IPSEC code paths.
