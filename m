From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net:add socket option for
 low latency polling
Date: Tue, 11 Jun 2013 08:58:52 -0700
Message-ID: <1370966332.3252.38.camel@edumazet-glaptop>
References: <20130611142415.17879.75569.stgit@ladj378.jer.intel.com>
	<20130611142438.17879.6389.stgit@ladj378.jer.intel.com>
	<1370961930.3252.32.camel@edumazet-glaptop>
	<51B74439.3030203@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51B74439.3030203@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2013-06-11 at 18:37 +0300, Eliezer Tamir wrote:
> On 11/06/2013 17:45, Eric Dumazet wrote:
> > On Tue, 2013-06-11 at 17:24 +0300, Eliezer Tamir wrote:
> >> adds a socket option for low latency polling.
> >> This allows overriding the global sysctl value with a per-socket one.
> >>
> >> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> >> ---
> >>
> >>
> >> -static inline cycles_t ll_end_time(void)
> >> +static inline cycles_t ll_end_time(struct sock *sk)
> >>   {
> >> -	return TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll) + get_cycles();
> >> +	return TSC_MHZ * ACCESS_ONCE(sk->sk_ll_usec) + get_cycles();
> >>   }
> >
> > Hmm, sk_ll_usec is an unsigned int.
> 
> We changed it to an unsigned long in v7, I guess that was gratuitous.
> Re-reading your comments on v6 2/5 I realize a cast would have sufficed.
> Should I send a patch to revert it to an unsigned int?

One sysctl as unsigned long was not a big deal so I was ok with your
change ;)

unsigned int for sk_ll_usec is enough, but using a 32x32->64bit multiply
is probably safer.





------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
