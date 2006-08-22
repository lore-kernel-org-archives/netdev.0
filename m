From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Get rid of /proc/sys/net/unix/max_dgram_qlen
Date: Wed, 23 Aug 2006 03:32:00 +0400
Message-ID: <20060822233200.GA20104@ms2.inr.ac.ru>
References: <4550.81.207.0.53.1156275903.squirrel@81.207.0.53> <20060822203914.GA9246@ms2.inr.ac.ru> <3794.81.207.0.53.1156285148.squirrel@81.207.0.53> <20060822223402.GA16459@ms2.inr.ac.ru> <1727.81.207.0.53.1156287240.squirrel@81.207.0.53>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:39582 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932217AbWHVXcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 19:32:01 -0400
To: Indan Zupancic <indan@nul.nu>
Content-Disposition: inline
In-Reply-To: <1727.81.207.0.53.1156287240.squirrel@81.207.0.53>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Isn't a socket freed until all skb are handled? In which case the limit on the number of open
> files limits the total memory usage? (Same as with streaming sockets?)

Alas. Number of closed sockets is not limited. Actually, it is limited
by sk_max_ack_backlog*max_files, which is a lot.

The problem is specific for unconnected datagram sockets
(predicate unix_peer(other) != sk)
