From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] wireless extensions: play with netns
Date: Wed, 17 Jun 2009 17:30:40 -0700
Message-ID: <m1my86qt73.fsf@fess.ebiederm.org>
References: <1245263058.31588.38.camel@johannes.local>
	<m1y6rqwpur.fsf@fess.ebiederm.org>
	<1245276899.31588.57.camel@johannes.local>
	<m1r5xitpdh.fsf@fess.ebiederm.org>
	<1245282099.31588.69.camel@johannes.local>
	<m17hzato0r.fsf@fess.ebiederm.org>
	<1245283327.31588.74.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1245283327.31588.74.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org> (Johannes Berg's message of "Thu\, 18 Jun 2009 02\:02\:06 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> writes:

> On Wed, 2009-06-17 at 16:54 -0700, Eric W. Biederman wrote:
>
>> > Subject: net: make namespace iteration possible under RCU
>> >
>> > We already call rcu_barrier(), so all we need to take
>> > care of is using proper RCU list add/del primitives.
>> 
>> This of course gives you a network namespace that can be found by for_each_net rcu
>> while the per net exit functions are running.  I think that opens up to races
>> that I don't want to think about.
>
> Indeed. Can we move the rcu_barrier() up? Or we could insert a
> synchronize_rcu() (which is sufficient for rcu_read_lock) before the
> exit functions are run?

I don't think we can move the barrier.   But adding an extra synchronize_rcu
should be fine.  We are talking about the slowest of the slow paths here.
It is so slow it even gets it's own kernel thread.

Eric
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
