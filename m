From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: skb_shinfo(skb)->nr_frags > 0 while skb_is_gso(skb) == 0?
Date: Wed, 7 Oct 2009 09:16:31 -0700
Message-ID: <20091007091631.2a151f27@nehalam>
References: <20091007010315.GA26498@neptune.jswright>
	<20091006182131.484d6e5a@nehalam>
	<20091007090420.GA1977@supernova.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Bob Montgomery <bob.montgomery@hp.com>
To: John Wright <john.wright@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43421 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755561AbZJGQRN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 12:17:13 -0400
In-Reply-To: <20091007090420.GA1977@supernova.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Oct 2009 03:04:20 -0600
John Wright <john.wright@hp.com> wrote:

> Hi Stephen,
> 
> On Tue, Oct 06, 2009 at 06:21:31PM -0700, Stephen Hemminger wrote:
> > On Tue, 6 Oct 2009 19:03:15 -0600
> > John Wright <john.wright@hp.com> wrote:
> > > Bob Montgomery and I are debugging an OOPS in the bnx2 driver.  The
> > > driver OOPSes in bnx2_tx_int(), getting a NULL pointer dereference when
> > > checking if the skb is GSO.  (This is on 2.6.29, before is_gso was
> > > cached in the tx_buf (commit d62fda08), but bear with me - while kernels
> > > with that commit might not crash in the same place, I think we have
> > > discovered a bug that would manifest itself another way.)
> > > 
> > > So, first, a question for someone who knows more about sk_buff's than I:
> > > is it reasonable/legal for an skb for which skb_is_gso(skb) == 0 to also
> > > have skb_shinfo(skb)->nr_frags > 0?
> > 
> > Yes, if driver support Scatter/Gather and Checksum offload,
> > TCP (especially splice) will hand fragmented frames to device.
> 
> Is there a good way to generate lots of these types of packets?  Is
> disabling tso and gso with ethtool and sendmsg()ing big chunks of data
> enough?
> 

netperf should be able to do this easily.  Also try NFS as well.

-- 
