From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Wed, 2 Oct 2013 16:24:36 -0500
Message-ID: <20131002212436.GC7824@sbohrermbp13-local.rgmadvisors.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
 <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
 <1380660769.19002.40.camel@edumazet-glaptop.roam.corp.google.com>
 <20131002173422.GA7824@sbohrermbp13-local.rgmadvisors.com>
 <1380737365.19002.110.camel@edumazet-glaptop.roam.corp.google.com>
 <20131002203507.GB7824@sbohrermbp13-local.rgmadvisors.com>
 <1380748118.19002.125.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:58892 "EHLO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753752Ab3JBVYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:24:40 -0400
Received: by mail-ie0-f182.google.com with SMTP id aq17so3400139iec.27
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 14:24:39 -0700 (PDT)
In-Reply-To: <1380748118.19002.125.camel@edumazet-glaptop.roam.corp.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 02, 2013 at 02:08:38PM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-02 at 15:35 -0500, Shawn Bohrer wrote:
> 
> > Sorry, I must be a little slow today.  I understand what you are
> > suggesting but I don't see how to implement it with a score.  Or at
> > least not without potentially changing existing behavior.  For example
> > I could make the inet->inet_daddr case add +100 to the score and I
> > would know that a score >= 100 was connected.  However, this would
> > unfairly favor that one case making a socket that only had a matching
> > inet_daddr be better than one that only had a matching inet_dport,
> > sk_bound_dev_if, and inet_rcv_saddr.
> > 
> 
> If early demux has to increment a socket refcount, then decrementing it
> because it found a non connected socket, this will be too expensive.
> 
> Also, keep in mind UDP chains can be long, so you should limit the early
> lookup to say a single socket.
> 
> TCP ehash is mostly empty (0 or 1 socket per bucket), so early demux
> really makes sense, but for UDP, there is no such property.

So... Are you suggesting that I just skip the early demux for unicast
UDP entirely?  That is fine by me since I only care about the
multicast case.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
