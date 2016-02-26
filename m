From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] uapi glibc compat: fix cases where glibc net/if.h is
 included before linux/if.h
Date: Fri, 26 Feb 2016 11:28:17 -0500 (EST)
Message-ID: <20160226.112817.1495300719463061587.davem@davemloft.net>
References: <1454853801-18064-1-git-send-email-mikko.rapeli@iki.fi>
	<20160217.104620.239734387234680136.davem@davemloft.net>
	<20160226072513.GH6104@lakka.kapsi.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemming@brocade.com, linux-api@vger.kernel.org,
 linux-kernel@vger.kernel.org, jwboyer@fedoraproject.org,
 pablo@netfilter.org, netdev@vger.kernel.org,
 netfilter-devel@vger.kernel.org, libc-alpha@sourceware.org
To: mikko.rapeli@iki.fi
Return-path: <libc-alpha-return-67666-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <20160226072513.GH6104@lakka.kapsi.fi>
List-Id: netdev.vger.kernel.org

From: Mikko Rapeli <mikko.rapeli@iki.fi>
Date: Fri, 26 Feb 2016 09:25:13 +0200

> (Adding libc-alpha list, review of https://lkml.org/lkml/2016/2/7/89 )
> 
> On Wed, Feb 17, 2016 at 10:46:20AM -0500, David Miller wrote:
>> From: Mikko Rapeli <mikko.rapeli@iki.fi>
>> Date: Sun,  7 Feb 2016 16:03:21 +0200
>> 
>> > @@ -68,6 +72,8 @@
>> >   * @IFF_ECHO: echo sent packets. Volatile.
>> >   */
>> >  enum net_device_flags {
>> > +/* for compatibility with glibc net/if.h */
>> > +#if __UAPI_DEF_IF_NET_DEVICE_FLAGS
>> >  	IFF_UP				= 1<<0,  /* sysfs */
>> >  	IFF_BROADCAST			= 1<<1,  /* volatile */
>> >  	IFF_DEBUG			= 1<<2,  /* sysfs */
>> > @@ -84,11 +90,14 @@ enum net_device_flags {
>> >  	IFF_PORTSEL			= 1<<13, /* sysfs */
>> >  	IFF_AUTOMEDIA			= 1<<14, /* sysfs */
>> >  	IFF_DYNAMIC			= 1<<15, /* sysfs */
>> > +#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS */
>> >  	IFF_LOWER_UP			= 1<<16, /* volatile */
>> >  	IFF_DORMANT			= 1<<17, /* volatile */
>> >  	IFF_ECHO			= 1<<18, /* volatile */
>> >  };
>> 
>> This is going to get messy is IFF_LOWER_UP, IFF_DORMANT, and IFF_ECHO
>> get added the the glibc header.  Why not just handle it now with
>> another __UAPI_DEF_FOO guard so that the additions to net/if.h can
>> deal with this case too.
> 
> Do you mean that the enum should be protected with a single guard or
> should I have one guard for current conflicts and one for the future
> if glibc headers include IFF_LOWER_UP and others?

I'm ambivalent about the mechanism, and I'm more concerned about covering
those three values in your change rather than eliding them.
