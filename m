From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 IPsec support
Date: Tue, 18 Feb 2003 23:33:01 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218.233301.98333082.davem@redhat.com>
References: <20030219134850.5f203ea7.Kazunori.Miyazawa@jp.yokogawa.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori.Miyazawa@jp.yokogawa.com
In-Reply-To: <20030219134850.5f203ea7.Kazunori.Miyazawa@jp.yokogawa.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


As promised, some more comments:

1) Please, can you split out seperate patch for changes
   to net/ipv4/xfrm_user.c?  They are independant.

   Kunihiro sent me identical patch, so please could you
   add him to credits in comment?  Thank you.

2) I believe that net/ipv6/xfrm_policy.c is another area
   for more code sharing.

   Any time that I see removal of 'static', it is clue to
   me :-)

   Short term you can do as I suggested for secpath_cachep
   issue, that is to move this new code to net/ipv4/xfrm_policy.c
   as it is, conditionalized by CONFIG_IPV6 || CONFIG_IPV6_MODULE.

   Later we can work on increased code sharing here.

3) I noticed comment above transformation from
   explicit dst->output() call to dst_output().

   It is not IPSEC issue, rather I believe that entire tree should
   have this conversion eventually.  The concept of stackable
   destination cache entries is a generic one.

4) I believe some module symbol exports are missing to handle
   ipv6 as module.

   For example, for skb_ah_walk and skb_esp_walk.

The rest of code looks fine to me.

Now is not the time to get picky about small details, let us only get
first draft basically correct.
