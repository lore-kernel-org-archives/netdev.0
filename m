From: Steve Hill <steve@navaho.co.uk>
Subject: Conntrack leak (2.6.2rc2)
Date: Mon, 2 Feb 2004 08:56:45 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402020854160.4039@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I've already posted this to the netfilter-devel list and had no response 
so I'm hoping that some of you might have some insight into the problem:

I'm using the 2.6.2rc2 kernel and have a strange connection tracking 
problem - when using unfragmented packets every thing is fine - a new 
connection is made and init_conntrack() is called, and as the session is 
timed out by conntrack, destroy_conntrack() is called.  Absolutely fine.

However, if I start a connection with a fragmented packet (i.e. my MTU 
is 1500 bytes, so "ping -c 1 -s 2500 172.16.0.1" sends a packet consisting 
of 2 fragments), init_conntrack() is called as usual, but when the session 
is timed out destroy_conntrack() never gets called.  This means that the 
memory for the connection is never freed and ip_conntrack_count is never 
decremented.  However, the connection is still removed from the hash 
table.  This means that it leaks memory, and eventually reaches 
ip_conntrack_max and starts dropping new connections.

-- 

- Steve Hill
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015

        ... Alcohol and calculus don't mix - Don't drink and derive! ...
