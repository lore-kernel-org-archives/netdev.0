From: Eric Paris <eparis@redhat.com>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
	buffer is large enough
Date: Mon, 10 Mar 2014 17:57:46 -0400
Message-ID: <1394488666.17193.16.camel@localhost>
References: <7457128.6VP2v68V93@x2> <87wqg8zfj4.fsf@xmission.com>
	<1394232722.17779.57.camel@flatline.rdu.redhat.com>
	<20140310.153001.1202621819107314058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rgb@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-audit@redhat.com, ebiederm@xmission.com,
        akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20140310.153001.1202621819107314058.davem@davemloft.net>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Mon, 2014-03-10 at 15:30 -0400, David Miller wrote:
> From: Eric Paris <eparis@redhat.com>
> Date: Fri, 07 Mar 2014 17:52:02 -0500
> 
> > The second user Eric patched, audit_send_list(), can grow without bound.
> > The number of skb's is going to be the size of the number of audit rules
> > that root loaded.  We run the list of rules, generate an skb per rule,
> > and add all of them to an skb_buff_head.  We then pass the skb_buff_head
> > to a kthread so that current will be able to read/drain the socket.
> > There really is no limit to how big the skb_buff_head could possibly
> > grow.  This doesn't necessarily absolutely have to be lossless but it
> > can actually quite reasonably be a whole lot of data that needs to get
> > sent.  I know of no way to deliver unbounded lengths of data to the
> > current task via netlink without blocking on more space in the socket.
> > Even if the socket rmem was MAX_INT, how can we deliver more?  The rule
> > size is unbounded.  How do I get an unbounded amount of data onto this
> > side of the socket when I have to generate it all during the request...
> 
> This is what netlink dumps  are for.  It is how we are able to dump
> routing tables with millions of routes to userspace.
> 
> By using normal netlink requests and netlink_unicast() for this, you
> are ignoring an entire mechanism in netlink designed specifically to
> handle this kind of situation.
> 
> Netlink dumps track state and build one or more SKBs (as necessary),
> one by one, to form the reply.  It implements flow control, state
> tracking for iteration, optimized SKB sizing and allocation, etc.

Awesome.  I'll see what I can find!
