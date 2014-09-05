From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net v2] ipv6: fix rtnl locking in setsockopt for anycast
 and multicast
Date: Fri, 5 Sep 2014 11:58:31 -0700
Message-ID: <CAHA+R7M1qd5g1ta=YFqefgXDf1EfF2_VsJGUvH6Dd+ttnHc_VQ@mail.gmail.com>
References: <20140901210520.GB25543@kria>
	<1409610378.21965.52.camel@localhost>
	<20140902082929.GA8483@kria>
	<20140905.115305.809714259412705649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tommi Rantala <tt.rantala@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	trinity@vger.kernel.org, Dave Jones <davej@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <20140905.115305.809714259412705649.davem@davemloft.net>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 5, 2014 at 11:53 AM, David Miller <davem@davemloft.net> wrote:
> From: Sabrina Dubroca <sd@queasysnail.net>
> Date: Tue, 2 Sep 2014 10:29:29 +0200
>
>> Calling setsockopt with IPV6_JOIN_ANYCAST or IPV6_LEAVE_ANYCAST
>> triggers the assertion in addrconf_join_solict()/addrconf_leave_solict()
>>
>> ipv6_sock_ac_join(), ipv6_sock_ac_drop(), ipv6_sock_ac_close() need to
>> take RTNL before calling ipv6_dev_ac_inc/dec. Same thing with
>> ipv6_sock_mc_join(), ipv6_sock_mc_drop(), ipv6_sock_mc_close() before
>> calling ipv6_dev_mc_inc/dec.
>>
>> This patch moves ASSERT_RTNL() up a level in the call stack.
>>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
>> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
>
> Applied and queued up for -stable, thanks.

I believe you applied a wrong version, at least the following
is not correct:

+       if (!dev)
+               return -ENODEV;

Sabrina took that from my draft patch, but they all don't
realize this is wrong.

(I did provide a correct version which is just ignored by you.)
