From: devnetfs <devnetfs@yahoo.com>
Subject: UDP receive path: is this safe?
Date: Sat, 23 Aug 2003 23:46:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030824064612.30641.qmail@web20414.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I've created an in-kernel udp socket and set sock->data_ready to
my function foo(). inside foo() i do a skb_recv_datagram() to get
(in noblock mode) the skb's received on the socket. 

is this safe/correct to do?  

as sock->data_ready() path for udp is:
udp_rcv() -> udp_queue_rcv_skb() -> sock_queue_rcv_skb() ->
data_ready()

and skb_recv_datagram() calls skb_dequeue()...

any possible races? as i think there can be multiples callers inside
foo() at the same time (correct?). but then skb_dequeue() should be
safe. but i am unsure of call-path from udp_rcv() to data_ready()?

please enlighten. 

i want to avoid the overhead of converting an skb to iovec (by 
calling udp_recvmsg) and hence pursuing this path.


thanks in advance,
A.



__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free, easy-to-use web site design software
http://sitebuilder.yahoo.com
