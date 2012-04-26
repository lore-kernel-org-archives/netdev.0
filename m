From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: Heavy spin_lock contention in __udp4_lib_mcast_deliver increase
Date: Thu, 26 Apr 2012 16:44:05 -0500
Message-ID: <20120426214405.GF2479@BohrerMBP.rgmadvisors.com>
References: <20120426151527.GA2479@BohrerMBP.rgmadvisors.com>
 <1335455595.2775.47.camel@edumazet-glaptop>
 <20120426162819.GD2479@BohrerMBP.rgmadvisors.com>
 <1335457888.2775.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:39449 "EHLO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753936Ab2DZVoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 17:44:08 -0400
Received: by mail-ob0-f178.google.com with SMTP id wc18so125157obb.9
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 14:44:07 -0700 (PDT)
In-Reply-To: <1335457888.2775.55.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 26, 2012 at 06:31:28PM +0200, Eric Dumazet wrote:
> On Thu, 2012-04-26 at 11:28 -0500, Shawn Bohrer wrote:
> 
> > No in this case it is 300 unique multicast addresses, and there is one
> > socket listening to each multicast address.  So a single message is
> > only copied once to a single socket.  The bottle neck appears to be
> > that even though a single message is only going to get copied to a
> > single socket we still have to walk the list of all 300 sockets while
> > holding the spin lock to figure that out.  The incoming packet rate is
> > also roughly evenly distributed across all 300 multicast addresses so
> > even though we have multiple receive queues they are all contending
> > for the same spin lock.
> > 
> 
> I repeat my question : Are these 300 sockets bound to the same UDP
> port ?
> 
> If not, they should be spreaded in hash table.
> 
> You can make this hash table very big to reduce hash collisions
> 
> Boot parameter : uhash_entries=65536

Thanks Eric I don't know how I missed this.  In my test all 300
sockets were bound to the same UDP port so they were all falling into
the same bucket.  Switching the test to use unique ports solves the
issue.

I didn't try your other patch to increase the stack size up to 512
sockets because I don't think we need it.  We rarely have more than a
single socket per machine receiving packets on a multicast address so
I think the current stack size is sufficient for us.  Or perhaps once
again I may be misunderstanding the purpose of that patch.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
