From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] XFRM: RFC4303 compliant auditing
Date: Fri, 21 Dec 2007 01:43:10 -0800 (PST)
Message-ID: <20071221.014310.155404661.davem@davemloft.net>
References: <20071220214200.12122.89628.stgit@flek.lan>
	<20071220214225.12122.48656.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	latten@austin.ibm.com
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59581
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750970AbXLUJnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:43:11 -0500
In-Reply-To: <20071220214225.12122.48656.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 20 Dec 2007 16:42:25 -0500

> This patch adds a number of new IPsec audit events to meet the auditing
> requirements of RFC4303.  This includes audit hooks for the following events:
> 
>  * Could not find a valid SA [sections 2.1, 3.4.2]
>    . xfrm_audit_state_notfound()
>    . xfrm_audit_state_notfound_simple()
> 
>  * Sequence number overflow [section 3.3.3]
>    . xfrm_audit_state_replay_overflow()
> 
>  * Replayed packet [section 3.4.3]
>    . xfrm_audit_state_replay()
> 
>  * Integrity check failure [sections 3.4.4.1, 3.4.4.2]
>    . xfrm_audit_state_icvfail()
> 
> While RFC4304 deals only with ESP most of the changes in this patch apply to
> IPsec in general, i.e. both AH and ESP.  The one case, integrity check
> failure, where ESP specific code had to be modified the same was done to the
> AH code for the sake of consistency.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

This doesn't apply at all to net-2.6.25, in particular
xfrm6_input_addr() doesn't even have a local variable
named "xfrm_vec_one" let alone the conditional where you're
adding the state notfound audit hook.

Please respin this and the third patch, thanks.
