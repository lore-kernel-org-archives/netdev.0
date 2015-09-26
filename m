From: Tejun Heo <tj@kernel.org>
Subject: Re: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sat, 26 Sep 2015 15:45:54 -0400
Message-ID: <20150926194554.GE3572@htj.duckdns.org>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <20150925150113.GD4449@mtj.duckdns.org>
 <20150926131621.GA16724@gondor.apana.org.au>
 <20150926180903.GD3572@htj.duckdns.org>
 <20150926194110.GA18815@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:34896 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbbIZTp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 15:45:59 -0400
Content-Disposition: inline
In-Reply-To: <20150926194110.GA18815@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Herbert.

On Sun, Sep 27, 2015 at 03:41:10AM +0800, Herbert Xu wrote:
> Thread 1			Thread 2
> sendmsg				getsockname
> 	netlink_autobind		netlink_getname
> 
> Thread 2 should not have to do anything special to guarantee that
> getsockname does not return garbage.  It must either be the bound
> portid if the autobind completed in thread 1 and is visible or it
> should return zero.
> 
> As it stands thread 2 may see a portid belonging to somebody else
> if it catches the autobind in thread 1 trying different portids
> while roving.

If the fact that thread 1 finished autobind isn't visible to thread 2,
it's valid for getsockname to return zero.  No ordering between the
two operations is defined.  If the fact that thread 1 finished
autobind is visible to thread 2, ordering is defined and because
ordering is transitive, by that very ordering, the port number is
visible to thread 2 too as long as thread 1 does proper barriering.

Thanks.

-- 
tejun
