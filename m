From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Tue, 19 Oct 2010 07:04:52 -0400
Message-ID: <20101019110452.GA14410@hmsreliant.think-freely.org>
References: <4CBCD429.8090306@windriver.com>
	<20101018234547.GA5703@hmsreliant.think-freely.org>
	<20101019021657.GZ8781@llucax.com.ar>
	<20101019.011649.71113115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, luca@llucax.com.ar,
	paul.gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20101019.011649.71113115.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2010 at 01:16:49AM -0700, David Miller wrote:
> From: Leandro Lucarella <luca@llucax.com.ar>
> Date: Mon, 18 Oct 2010 23:16:57 -0300
> 
> > 
> > The problem is not between the tipc stacks in different hosts, is
> > between the tipc stack and the applications using it (well, maybe
> > there is a problem somewhere else too).
> > 
> > This was a deliberate API change, not a subtle bug...
> 
> Neil et al., if these packets live only between the kernel stack
> and the userspace API layer, we should not be byte-swapping this
> stuff and we need to fix this fast.
> 
Copy that Dave.  I think I see the problem.  The subscription code handles
messages both off the wire and from local user space.  The off the wire case
should work because the subscription code assumes that all the incomming data is
in network byte order, but user space is an exception to that rule as its in
local byte order.  I'll have a patch together for Leandro to test soon.
Neil

> Thanks.
> 

------------------------------------------------------------------------------
Download new Adobe(R) Flash(R) Builder(TM) 4
The new Adobe(R) Flex(R) 4 and Flash(R) Builder(TM) 4 (formerly 
Flex(R) Builder(TM)) enable the development of rich applications that run
across multiple browsers and platforms. Download your free trials today!
http://p.sf.net/sfu/adobe-dev2dev
