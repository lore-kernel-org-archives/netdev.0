From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Race between neigh_timer_handler and neigh_event_send
Date: Tue, 5 Oct 2004 11:57:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005115725.7aa6c739.davem@davemloft.net>
References: <20041005101532.GA935@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20041005101532.GA935@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Good catch Greg.

All of this trouble is because this is the one spot where we
make reference to the arp_queue packets without neigh->lock
held.

I wish we could avoiding dropping the lock instead, but that
is not the case.  All of these ->solicit() methods can end
up calling back down into the neighbour layer and try to grab
the lock again.

I'll apply your patch, thanks.
