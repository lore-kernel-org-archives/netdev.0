From: "David S. Miller" <davem@redhat.com>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Thu, 22 Apr 2004 11:28:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040422112801.2a1a4a57.davem@redhat.com>
References: <XFMail.20040422102359.pochini@shiny.it>
	<Pine.LNX.4.53.0404220734330.8039@chaos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pochini@shiny.it, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        cfriesen@nortelnetworks.com, joern@wohnheim.fh-wedel.de
Return-path: <netdev-bounce@oss.sgi.com>
To: root@chaos.analogic.com
In-Reply-To: <Pine.LNX.4.53.0404220734330.8039@chaos>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 22 Apr 2004 07:35:54 -0400 (EDT)
"Richard B. Johnson" <root@chaos.analogic.com> wrote:

> Has anybody checked to see what Linux does if it receives a
> RST to the broadcast address? It would be a shame if all
> connections were dropped!

int tcp_v4_rcv(struct sk_buff *skb)
{
 ...
	if (skb->pkt_type != PACKET_HOST)
		goto discard_it;

Packets which are multicast or broadcast do not get marked
as "PACKET_HOST".
