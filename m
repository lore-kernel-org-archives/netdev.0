From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Thu, 07 Apr 2005 16:36:41 -0700
Message-ID: <1112917001.3893.77.camel@beastie>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
	 <42540CF3.7070501@cs.wisc.edu> <20050406212906.GA24775@gondor.apana.org.au>
	 <1112823442.16753.68.camel@beastie>
	 <20050406220417.GA4443@gondor.apana.org.au>
	 <1112826385.16753.99.camel@beastie>
	 <20050407213231.GA28738@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Christie <michaelc@cs.wisc.edu>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050407213231.GA28738@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-04-08 at 07:32 +1000, Herbert Xu wrote:
> On Wed, Apr 06, 2005 at 03:26:25PM -0700, Dmitry Yusupov wrote:
> > 
> > Messages from kernel are asynchronous and there are no alloc_skb on "up"
> > calls. It is "mempooled out" on interface level. (see Open-iSCSI
> > interface). Messages to kernel requires copy_from_user to newly
> > allocated skb, here is where we need sk_allocation bit set. Those
> > messages are synchronous from daemon perspective. If "down" call fails,
> > we will re-try later or take some other management action. We assuming
> > that later OOM-killer will free some memory for us and atomic allocation
> > will succeed eventually.
> 
> I presume you only need to send one message at a time of a fixed size.
> Would it better to always have an skb allocated for the socket so that
> we don't need to allocate at sendmsg time?

This actually even better since we will guarantee "down" call delivery.
My only concern is that it is not very generic. Do you know clean way to
implement it?
