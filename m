From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: fix rtnl locking in setsockopt for
 anycast and multicast
Date: Fri, 05 Sep 2014 12:21:57 -0700 (PDT)
Message-ID: <20140905.122157.2149128504245355664.davem@davemloft.net>
References: <20140902082929.GA8483@kria>
	<20140905.115305.809714259412705649.davem@davemloft.net>
	<CAHA+R7M1qd5g1ta=YFqefgXDf1EfF2_VsJGUvH6Dd+ttnHc_VQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, hannes@stressinduktion.org,
	tt.rantala@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trinity@vger.kernel.org,
	davej@redhat.com
To: cwang@twopensource.com
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7M1qd5g1ta=YFqefgXDf1EfF2_VsJGUvH6Dd+ttnHc_VQ@mail.gmail.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <cwang@twopensource.com>
Date: Fri, 5 Sep 2014 11:58:31 -0700

> On Fri, Sep 5, 2014 at 11:53 AM, David Miller <davem@davemloft.net> wrote:
>> From: Sabrina Dubroca <sd@queasysnail.net>
>> Date: Tue, 2 Sep 2014 10:29:29 +0200
>>
>>> Calling setsockopt with IPV6_JOIN_ANYCAST or IPV6_LEAVE_ANYCAST
>>> triggers the assertion in addrconf_join_solict()/addrconf_leave_solict()
>>>
>>> ipv6_sock_ac_join(), ipv6_sock_ac_drop(), ipv6_sock_ac_close() need to
>>> take RTNL before calling ipv6_dev_ac_inc/dec. Same thing with
>>> ipv6_sock_mc_join(), ipv6_sock_mc_drop(), ipv6_sock_mc_close() before
>>> calling ipv6_dev_mc_inc/dec.
>>>
>>> This patch moves ASSERT_RTNL() up a level in the call stack.
>>>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
>>> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
>>
>> Applied and queued up for -stable, thanks.
> 
> I believe you applied a wrong version, at least the following
> is not correct:
> 
> +       if (!dev)
> +               return -ENODEV;
> 
> Sabrina took that from my draft patch, but they all don't
> realize this is wrong.
> 
> (I did provide a correct version which is just ignored by you.)

Not ignored, but rather it was hard to interpret the situation due to
poor communication in the feedback emails.

The onus is on you guys to communicate things precisely so that I
understand what patch is in what state.
