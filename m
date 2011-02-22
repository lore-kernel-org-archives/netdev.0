From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] bonding: fix user-controlled queuing
	issues
Date: Tue, 22 Feb 2011 16:24:45 -0500
Message-ID: <20110222212445.GF11864@gospo.rdu.redhat.com>
References: <1298328783-10073-1-git-send-email-andy@greyhouse.net> <20110222155518.GA14991@linuxace.com> <20110222161941.GE11864@gospo.rdu.redhat.com> <20110222164836.GA15040@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753685Ab1BVVZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 16:25:12 -0500
Content-Disposition: inline
In-Reply-To: <20110222164836.GA15040@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 22, 2011 at 08:48:36AM -0800, Phil Oester wrote:
> On Tue, Feb 22, 2011 at 11:19:41AM -0500, Andy Gospodarek wrote:
> > Phil,
> > 
> > Can you send me the minimal set of tc rules that selects output queue 16
> > and the output of /proc/net/bonding/bond0?
> > 
> > Private email is fine if you do not want to post it to the list.
> > 
> > Thanks,
> > 
> > -andy
> 
> I have no tc rules which select output queue 16 (I have no tc rules at all
> in fact). 
> 
> Output of /proc/net/bonding/bond0 below.  The bond consists of two Intel
> igb nics, which only have 8 queues.  Note, however, that eth0 is an ixgbe,
> which has 16 queues:
> 
> ixgbe 0000:0b:00.0: Multiqueue Enabled: Rx Queue count = 16, Tx Queue count = 16
> 
> which may answer your question as to what is selecting queue 16.  
> 
> Phil 
> 

OK, I've got it now!  I can reproduce this when I recieve frames from a
device not in the bond and transmit those frames out of the bond device.
I suspect that is what you are doing.  That was a case I did not
consider with the original patch.

I will test all of this and post this as a 2-part series with the first
patch being one that should apply to stable as well, so you and others
can have it there.

