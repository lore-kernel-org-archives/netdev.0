From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] net: fix a potential rcu_read_lock() imbalance in
 rt6_fill_node()
Date: Tue, 27 Mar 2012 13:25:51 -0700
Message-ID: <20120327202551.GA15798@kroah.com>
References: <4F70E308.7070908@candelatech.com>
 <20120326.174945.1186427809261872546.davem@davemloft.net>
 <4F70E560.3020102@candelatech.com>
 <4F70F688.6050108@candelatech.com>
 <1332805148.3547.14.camel@edumazet-glaptop>
 <4F71EF2A.8020507@candelatech.com>
 <1332877149.3547.24.camel@edumazet-glaptop>
 <1332878032.3547.39.camel@edumazet-glaptop>
 <4F722045.80902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dave Jones <davej@redhat.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:32963 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab2C0UZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 16:25:56 -0400
Received: by yhmm54 with SMTP id m54so296152yhm.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 13:25:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4F722045.80902@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 27, 2012 at 01:17:09PM -0700, Ben Greear wrote:
> On 03/27/2012 12:53 PM, Eric Dumazet wrote:
> >Commit f2c31e32b378 (net: fix NULL dereferences in check_peer_redir() )
> >added a regression in rt6_fill_node(), leading to rcu_read_lock()
> >imbalance.
> >
> >Thats because NLA_PUT() can make a jump to nla_put_failure label.
> >
> >Fix this by using nla_put()
> >
> >Many thanks to Ben Greear for his help
> >
> >Reported-by: Ben Greear<greearb@candelatech.com>
> >Reported-by: Dave Jones<davej@redhat.com>
> >Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> 
> This does indeed fix the problem for me (tested in the 3.0.25 kernel).
> So, please feel free to add:
> 
> Tested-by: Ben Greear <greearb@candelatech.com>

Very nice job Eric, thanks for tracking this down.

greg k-h
