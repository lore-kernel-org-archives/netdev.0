From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Tue, 16 Sep 2003 08:05:07 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200309160805.08171.bdschuym@pandora.be>
References: <200309022116.41697.bdschuym@pandora.be> <200309132159.37834.bdschuym@pandora.be> <20030915155903.12a3f95d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, acme@conectiva.com.br,
	netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030915155903.12a3f95d.davem@redhat.com>
Content-Disposition: inline
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Tuesday 16 September 2003 00:59, David S. Miller wrote:
> > -	char physindev[IFNAMSIZ];
> > +	char physindev[IFNAMSIZ] __attribute__ ((aligned (__alignof__(unsigned
> > int))));
>
> I have to reject the fix for this problem again.
>
> You can't change the struct exported to userspace in any way
> without breaking the tools.  I tried to explain this in the
> first revision of your change.

On Thursday 04 September 2003 05:05, you wrote:
<quote>
As I mentioned in another email, this patch can't be used, it
breaks in mixed 32/64 bit environments.
<unquote>

I guess I'm a bit on the slow side but I didn't quite read the above text like 
that.
Anyway, this rule about not changing structs exported to userspace truly 
sucks, IMHO. If someone decides to compile her own kernel this person should 
not expect every userspace tool to keep working, again IMHO. Adding a new 
module to the kernel results in the user having to upgrade her tools, 
recompiling won't even do. Why on earth do you allow adding modules.
But I'm sure some nice volunteer will come along and downgrade that code 
fragment.

Bart
