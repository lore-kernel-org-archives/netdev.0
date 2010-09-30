From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 1/2] genetlink: introduce pre_doit/post_doit hooks
Date: Fri, 1 Oct 2010 09:14:22 +1000
Message-ID: <AANLkTinTZG9U9AKXSgGK8GVLuweaBb48Gm9STOs40OQp@mail.gmail.com>
References: <20100930211013.472957770@sipsolutions.net> <20100930211131.021309930@sipsolutions.net>
 <AANLkTik9+zA4PPPx=q6CRM-sgOjjECJdtJTgkCG9pGAY@mail.gmail.com>
 <1285886690.5137.28.camel@jlt3.sipsolutions.net> <1285886821.5137.29.camel@jlt3.sipsolutions.net>
 <1285886955.5137.31.camel@jlt3.sipsolutions.net> <AANLkTimVMGHNkK=o650qzZfvUp3mWRAG_=60etVbEBxh@mail.gmail.com>
 <1285887352.5137.34.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tgraf-G/eBtMaohhA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1285887352.5137.34.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 1, 2010 at 08:55, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Fri, 2010-10-01 at 08:51 +1000, Julian Calaby wrote:
>
>> > Come to think of it -- I could get away with a single pointer, since, if
>> > both are assigned,
>> >
>> > user_ptr[0] == wiphy_to_rdev(((netdev *)user_ptr[1])->ieee80211_ptr->wiphy)
>> >
>> > but that's a lot of pointy things, and some functions only have the rdev
>> > so it gets more complex. I think allowing two private pointers is a
>> > decent compromise.
>>
>> Come to think of it -- if someone wanted to have a massive structure
>> with 10 pointers and a set of random data structures, then they could
>> easily create their priv struct and assign it to user_ptr[0], hence
>> rendering my argument null and void.
>
> Oh, well, I thought your argument was that it was arbitrary and not
> really necessary :-)

My argument was more that someone's likely to come up with a scheme
that requires more than 2 pointers, so why not accommodate them from
start with an element for a priv struct - but that requires a new
struct, allocating and freeing it, as well as heap space for it, and a
pointer on the stack to it. (though I'm sure there'll be some sensible
way to make them persistent, but that's another issue)

> Also, this rather cheap, it just needs a bit more stack space in a place
> that isn't typically deeply nested. So if some protocol came around and
> needed three pointers, I'd probably advocate just bumping it to three.
> At some point I might draw a line (10 is probably too much).

I was considering pointing out that a compromise might need to be
made, but I figured you'd already thought of that =)

> But you're right, of course, they can just use the first one and put
> something dynamically allocated into that, if really needed.

Exactly.

Thanks,

-- 

Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
