From: Neil Horman <nhorman@redhat.com>
Subject: Re: __kfree_skb eventually calls kfree_skb violating dropwatch
 assumption
Date: Fri, 14 Oct 2011 10:54:31 -0400
Message-ID: <20111014145431.GF15962@hmsreliant.think-freely.org>
References: <27F465BDABE6954AABB2A4E3599BDAC702AD1DC3A7@sausexmbp02.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Suresh, Charles" <Charles.Suresh@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51174 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754904Ab1JNOyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 10:54:35 -0400
Content-Disposition: inline
In-Reply-To: <27F465BDABE6954AABB2A4E3599BDAC702AD1DC3A7@sausexmbp02.amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2011 at 09:17:56PM -0500, Suresh, Charles wrote:
> kfree_skb can be called from __kfree_skb through the following call chain :
> 
> kfree_skb  <- skb_drop_list <- skb_drop_fraglist <- skb_release_data <-  skb_release_all <- __kfree_skb (on the 2.38.4 kernel).
> 
> This violates the assumption in the dropwatch tool that discarded packets go through the kfree_skb path and all others must go through the consume_skb path (thus resulting in the over-counting of discarded packets in dropwatch).
> 
> Neil Horman the author of dropwatch suggested that this could be fixed by skb_drop_list calling consume_skb instead of kfree_skb.
> 
> Charles
> 

Acutally, looking closer at this, I think we dont' even really need to change
anything, Once acme is done pushing the changes that enable easier user space
symbol matching, I can just modify the dropwatch perf script and user space tool
to filter traces of kfree_skb that occur from skb_drop_list.  The only two
places that call is used is from pskb_trim and via a call to kfree_skb or
consume_skb.  Neither call should be considered and independent drop event.

Neil
