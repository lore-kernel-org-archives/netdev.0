From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: skb_shinfo(skb)->nr_frags > 0 while skb_is_gso(skb) == 0?
Date: Tue, 6 Oct 2009 18:21:31 -0700
Message-ID: <20091006182131.484d6e5a@nehalam>
References: <20091007010315.GA26498@neptune.jswright>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Bob Montgomery <bob.montgomery@hp.com>
To: John Wright <john.wright@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34278 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758538AbZJGBXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2009 21:23:14 -0400
In-Reply-To: <20091007010315.GA26498@neptune.jswright>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Oct 2009 19:03:15 -0600
John Wright <john.wright@hp.com> wrote:

> Hello,
> 
> Bob Montgomery and I are debugging an OOPS in the bnx2 driver.  The
> driver OOPSes in bnx2_tx_int(), getting a NULL pointer dereference when
> checking if the skb is GSO.  (This is on 2.6.29, before is_gso was
> cached in the tx_buf (commit d62fda08), but bear with me - while kernels
> with that commit might not crash in the same place, I think we have
> discovered a bug that would manifest itself another way.)
> 
> So, first, a question for someone who knows more about sk_buff's than I:
> is it reasonable/legal for an skb for which skb_is_gso(skb) == 0 to also
> have skb_shinfo(skb)->nr_frags > 0?

Yes, if driver support Scatter/Gather and Checksum offload,
TCP (especially splice) will hand fragmented frames to device.

Don't know what assumptions driver is making that could cause your
issue.
