From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: Sat, 18 Dec 2004 22:00:54 +0100
Message-ID: <20041218210054.GI17998@postel.suug.ch>
References: <20041218170017.GH17998@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041218170017.GH17998@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Correctly handle shared and cloned skbs by copying them before writing
> and dequeue unwriteable skbs unchanged. Assumes that IP/IPv6 header
> is always linear so no pulling required.

Hmm.. OTOH, setting skb->tc_index in enqueue() might need a pskb_copy() in
some cases. I'm not aware of such a path though, does anyone know about
a path where it would be required?  If so it would be better to make the
skb writeable in enqueue() to safe a copy.
