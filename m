From: Kazunori MIyazawa <kazunori@miyazawa.org>
Subject: Re: (usagi-core 11926) Re: [PATCH] IPv6 IPsec support
Date: Wed, 19 Feb 2003 23:39:15 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030219233915.130a26e3.kazunori@miyazawa.org>
References: <20030219134850.5f203ea7.Kazunori.Miyazawa@jp.yokogawa.com>
	<20030218.233301.98333082.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, Kazunori.Miyazawa@jp.yokogawa.com, netdev@oss.sgi.com,
   kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-core@linux-ipv6.org
In-Reply-To: <20030218.233301.98333082.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thank you, David.

On Tue, 18 Feb 2003 23:33:01 -0800 (PST)
"David S. Miller" <davem@redhat.com> wrote:

> 
> As promised, some more comments:
> 
> 1) Please, can you split out seperate patch for changes
>    to net/ipv4/xfrm_user.c?  They are independant.
> 
>    Kunihiro sent me identical patch, so please could you
>    add him to credits in comment?  Thank you.
> 
OK. We will do it.

> 2) I believe that net/ipv6/xfrm_policy.c is another area
>    for more code sharing.
> 
>    Any time that I see removal of 'static', it is clue to
>    me :-)
> 
>    Short term you can do as I suggested for secpath_cachep
>    issue, that is to move this new code to net/ipv4/xfrm_policy.c
>    as it is, conditionalized by CONFIG_IPV6 || CONFIG_IPV6_MODULE.
> 
>    Later we can work on increased code sharing here.
>
 
I see, I will move ours into net/ipv4/xfrm_policy.c

> 3) I noticed comment above transformation from
>    explicit dst->output() call to dst_output().
> 
>    It is not IPSEC issue, rather I believe that entire tree should
>    have this conversion eventually.  The concept of stackable
>    destination cache entries is a generic one.
> 

Please let me understand. I think dst->output calls each dst
output routine chains but those could not process the return value 
NET_XMIT_BYPASS returned from ah and/or esp.
Is this out of scope of IPsec?

> 4) I believe some module symbol exports are missing to handle
>    ipv6 as module.
> 
>    For example, for skb_ah_walk and skb_esp_walk.
> 
Thank you, I will check them.

--Kazunori Miyazawa (Yokogawa Electric Corporation)
