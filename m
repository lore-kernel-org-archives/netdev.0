From: Stephen Smalley <sds@epoch.ncsc.mil>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Mon, 14 Feb 2005 08:08:19 -0500
Message-ID: <1108386498.15437.26.camel@moss-spartans.epoch.ncsc.mil>
References: <20050212010109.V24171@build.pdx.osdl.net>
	 <20050212010243.W24171@build.pdx.osdl.net>
	 <20050212010504.X24171@build.pdx.osdl.net> <420E334B.8060805@eurodev.net>
	 <420E77FA.6080007@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com, davem@davemloft.net,
        James Morris <jmorris@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <420E77FA.6080007@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-02-12 at 16:41, Pablo Neira wrote:
> With your patch, a message from user space process that doesn't have the 
> capabilites follows this path:
> 
> sys_sendmsg() -> netlink_sendmsg() -> netlink_unicast() -> 
> netlink_sendskb() = discarded here.
> 
> Currently, it continues, for example in case of rtnetlink:
> 
> ... -> netlink_sendskb() -> sk_data_ready(sk, len) -> rtnetlink_rcv() -> 
> rtnetlink_rcv_skb() -> rtnetlink_rcv_msg() = discarded here.
> 
> Nowadays the message is enqueued but it's discarded later. So if I'm not 
> missing anything, I don't see the point of adding a new function to 
> check for capabilities/audit stuff just a bit before.

Two reasons:
1) The sender-side checks allow checking (and auditing) based on the
current task's credentials, vs. having to save the information in the
netlink_skb_parms for use on the receiver side.
2) Performing the check up front at send time allows the kernel to
reject it early and reduce extraneous processing / resource consumption
by unauthorized processes.

-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency
