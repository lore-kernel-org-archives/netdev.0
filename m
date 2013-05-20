From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v2 net-next 1/4] net: implement support
 for low latency socket polling
Date: Mon, 20 May 2013 12:39:59 +0300
Message-ID: <5199EF6F.9040008@linux.intel.com>
References: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
	<20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
	<20130520.005447.972811583292360876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, hpa@zytor.com,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	andi@firstfloor.org, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130520.005447.972811583292360876.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 20/05/2013 10:54, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Sun, 19 May 2013 13:25:33 +0300
>
>> +#else /* CONFIG_INET_LL_RX_FLUSH */
>> +
>> +#define sk_valid_ll(sk) 0
>> +#define sk_poll_ll(sk, nonblock) do {} while (0)
>> +#define skb_mark_ll(napi, skb) do {} while (0)
>> +#define sk_mark_ll(sk, skb) do {} while (0)
>
> Make these inline functions too, so that even if
> CONFIG_INET_LL_RX_POLL is disabled, the arguments and return values
> are still properly type checked.

Is this what you had in mind?

static inline bool sk_valid_ll(struct sock *sk)
{
	return 0;
}

static inline bool sk_poll_ll(struct sock *sk, int noblock)
{
	return 0;
}

static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct 
*napi)
{
}

static inline voiv sk_mark_ll(struct sock *sk, struct sk_buff *skb)
{
}

would you like me to resend the whole set or just this patch?

Thanks,
Eliezer

------------------------------------------------------------------------------
AlienVault Unified Security Management (USM) platform delivers complete
security visibility with the essential security capabilities. Easily and
efficiently configure, manage, and operate all of your security controls
from a single console and one unified framework. Download a free trial.
http://p.sf.net/sfu/alienvault_d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
