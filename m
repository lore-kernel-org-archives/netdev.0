From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Sat, 12 Feb 2005 22:41:14 +0100
Message-ID: <420E77FA.6080007@eurodev.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <20050212010504.X24171@build.pdx.osdl.net> <420E334B.8060805@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com, davem@davemloft.net,
        jmorris@redhat.com, sds@epoch.ncsc.mil, serue@us.ibm.com
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <420E334B.8060805@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pablo Neira wrote:

> I also see another option which is passing as parameter such function 
> which check for capabilities/audit stuff to my netlink_process_skb 
> function, calling it before process_msg. But in that case, the packet 
> sent by a sender that doesn't has the right to was already enqueued. I 
> understand that this is exactly what you are trying to avoid.


With your patch, a message from user space process that doesn't have the 
capabilites follows this path:

sys_sendmsg() -> netlink_sendmsg() -> netlink_unicast() -> 
netlink_sendskb() = discarded here.

Currently, it continues, for example in case of rtnetlink:

... -> netlink_sendskb() -> sk_data_ready(sk, len) -> rtnetlink_rcv() -> 
rtnetlink_rcv_skb() -> rtnetlink_rcv_msg() = discarded here.

Nowadays the message is enqueued but it's discarded later. So if I'm not 
missing anything, I don't see the point of adding a new function to 
check for capabilities/audit stuff just a bit before.

--
Pablo
