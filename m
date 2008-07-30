From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC][PATCH 1/2] net: support for TX timestamps
Date: Wed, 30 Jul 2008 15:34:16 +0200
Message-ID: <1217424856.30512.180.camel@ecld0pohly>
References: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com>
	 <1217291753-5322-2-git-send-email-opurdila@ixiacom.com>
	 <1217421813.30512.169.camel@ecld0pohly>
	 <200807301615.52953.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42161 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116AbYG3NgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 09:36:13 -0400
In-Reply-To: <200807301615.52953.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-30 at 16:15 +0300, Octavian Purdila wrote:
> On Wednesday 30 July 2008, Patrick Ohly wrote:
> > Is skb->sk always guaranteed to be set in hard_start_xmit?
> > skb_tx_timestamp() depends on it. In 2.6.23 the field always seemed to
> > be valid, but in 2.6.26 I think I have seen NULL pointers there for PTP
> > UDP broadcasts.
> 
> I don't think that skb->sk is guaranteed to be around in hard_start_xmit. But 
> we should not need it, if we overload the skb->tstamp, right?

skb->sk is needed in skb_tx_timestamp() to send the copied skb with the
time stamp back to the application, isn't it? skb_tx_timestamp() won't
crash, but it won't be able to do the desired action either. Overloading
skb->tstamp doesn't help with that.

I don't know where the connection to the originating socket is lost, but
in linux-2.6 as of one week ago (not 2.6.26, as I said above) the
skb->sk pointer is indeed NULL for the PTP broadcast packets - I just
checked again.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

