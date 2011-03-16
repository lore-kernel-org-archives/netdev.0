From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 status...
Date: Wed, 16 Mar 2011 10:42:36 -0700 (PDT)
Message-ID: <20110316.104236.104065822.davem@davemloft.net>
References: <20110316.000251.189704695.davem@davemloft.net>
	<20110316073803.GB2780@psychotron.redhat.com>
	<20110316084022.GA2845@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
	linville@tuxdriver.com, kaber@trash.net
To: jpirko@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110316084022.GA2845@psychotron.brq.redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 16 Mar 2011 09:40:23 +0100

> Wed, Mar 16, 2011 at 08:38:03AM CET, jpirko@redhat.com wrote:
>>Wed, Mar 16, 2011 at 08:02:51AM CET, davem@davemloft.net wrote:
>>>From: Jiri Pirko <jpirko@redhat.com>
>>>Date: Wed, 16 Mar 2011 07:50:09 +0100
>>>
>>>>>Jiri, I know there is your patch set there, but I think you and Changli
>>>>>still need to go back and forth one more time wrt. orig_dev semantics.
>>>>>Since you have been posting this patch set for some time I'm still
>>>>>willing to apply it for this merge window, but please make haste and
>>>>>work out the remaining discussion.  Thank you.
>>>> 
>>>> Dave, you can apply the rest of the series and leave only the first
>>>> patch (af_packet) out. There's no dependency. We will figure out things
>>>> around origdev later.
>>>
>>>I was about to do that but I've found other problems.
>>>
>>>You cannot make the modifications you make to linux/if.h, those
>>>interface flags are visible to userspace.
>>
>>What do you suggest? To remove unused flags and leave gaps there or to
>>not to remove the flags at all?
> 
> Well, the following comment:
> <quote>
> /* Private (from user) interface flags (netdevice->priv_flags). */
> </quote>
> leads me to think that these flags should not be used by userspace.
> So maybe it may not be problem to change those values.

Comments don't block user applications from using defines we expose
to them.  The person who was wise enough to write that comment should
have also been wise enough to add appropriate __KERNEL__ protection
to the definitions.

They were not, therefore we are stuck with them forever.
