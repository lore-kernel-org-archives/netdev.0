From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Last night Linus bk - netfilter busted?
Date: Fri, 11 Mar 2005 10:51:36 -0800
Message-ID: <20050311105136.2a5e4ddc.davem@davemloft.net>
References: <200503110223.34461.dtor_core@ameritech.net>
	<4231A498.4020101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dtor_core@ameritech.net,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4231A498.4020101@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Mar 2005 15:00:56 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Works fine here. You could try if reverting one of these two patches
> helps (second one only if its a SMP box).
> 
> ChangeSet@1.2010, 2005-03-09 20:28:17-08:00, bdschuym@pandora.be
>    [NETFILTER]: Reduce call chain length in netfilter (take 2)

It's this change, I know it is, because Linus sees the same problem
on his workstation.

You wouldn't happen to be seeing this problem on a PPC box would
you?  Since Linus's machine is a PPC machine too, that would support
my theory that this could be a compiler issue on that platform.

Damn, wait, Patrick, I think I know what's happening.  The iptables
IPT_* verdicts are dependant upon the NF_* values, and they don't
cope with Bart's changes I bet.  Can you figure out what the exact
error would be?  This kind of issue would explain the looping inside
of ipt_do_table(), wouldn't it?
