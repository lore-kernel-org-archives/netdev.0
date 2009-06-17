From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] wireless extensions: play with netns
Date: Wed, 17 Jun 2009 16:24:58 -0700
Message-ID: <m1r5xitpdh.fsf@fess.ebiederm.org>
References: <1245263058.31588.38.camel@johannes.local>
	<m1y6rqwpur.fsf@fess.ebiederm.org>
	<1245276899.31588.57.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1245276899.31588.57.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org> (Johannes Berg's message of "Thu\, 18 Jun 2009 00\:14\:59 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> writes:

> On Wed, 2009-06-17 at 13:46 -0700, Eric W. Biederman wrote:
>> Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> writes:
>> 
>> > This makes wireless extensions netns aware.
>> >
>> > Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
>> > ---
>> > Is this ok, or is this racy? I guess what I'm asking is -- will
>> > for_each_net() stop iterating over a netns that is going away before the
>> > pernet exit op is called? If yes, this should be fine.
>> 
>> for_each_net requires the rtnl_lock or the net_mutex to be safe.
>> You aren't taking either so your code is racy.
>
> So it looks like I can also use rcu_read_lock(), but there's no
> for_each_net_rcu(), should there be?

I'm not using rcu safe list manipulation.  What makes it look like
rcu_read_lock() is safe?

Eric
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
