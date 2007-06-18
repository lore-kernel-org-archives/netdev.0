From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 12:43:40 +0200
Message-ID: <20070618104340.GZ521@postel.suug.ch>
References: <E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu> <20070618.021813.105401188.davem@davemloft.net> <E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu> <20070618.023520.102546505.davem@davemloft.net> <E1I0DmJ-0006yg-00@dorka.pomaz.szeredi.hu> <20070618103241.GX521@postel.suug.ch> <E1I0EdX-0007Ia-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	viro@ftp.linux.org.uk, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38298 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752941AbXFRKnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 06:43:20 -0400
Content-Disposition: inline
In-Reply-To: <E1I0EdX-0007Ia-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Miklos Szeredi <miklos@szeredi.hu> 2007-06-18 12:39
> You are wrong.  Look in unix_release_sock():
> 
> 	if (atomic_read(&unix_tot_inflight))
> 		unix_gc();		/* Garbage collect fds */
> 
> 
> unix_tot_inflight is the number of AF_UNIX sockets currently being
> transferred over some AF_UNIX sockets.
> 
> That means that just sending (non-unix socket) fds over unix sockets
> will never invoke the gc.

That's what I meant, I'm sorry, I should have written unix socket
file descriptor to not leave any room for misinterpretation.
