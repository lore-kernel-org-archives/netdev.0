From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] netdev_ops
Date: Wed, 09 Jul 2003 10:11:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0C4CA8.7090502@candelatech.com>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> Changes since yesterday's patch:
> 
>  - Make all methods take the struct net_device as suggested by Ben Greear.
>  - Rename self_test_len() and get_stats_len() to *_count() to reflect
>    that they return a count of elements, not a byte length.
>  - Related bugfixes.
>  - Remove the get_strings_len() method; we now infer the length from
>    either self_test_count() or get_stats_count().
>  - memset() the drvinfo struct so it doesn't leak information from the
>    kernel stack (existing bug in tg3).
>  - Clamp regs.len in ethtool.c rather than in the driver.
>  - Pass the stringset value to get_strings() rather than a pointer to
>    the whole ethtool_gstrings struct.
> 
> I have a question about the error return values in ethtool_get_strings().
> Are -EOPNOTSUPP and -EINVAL the right ones to use in the case statement?
> Or should I perhaps be using -ENOSYS instead of EINVAL?  I've noticed
> drepper tends to prefer this for unimplemented subops.  Since this is
> an ioctl(), perhaps I should be using -ENOTTY instead ;-)

Considering any number of things may change in the future, what do
you think of adding a global 'nettool-version' method.  That could
allow user-space code to take appropriate action if something ever
changes in a non-compatible way....

Also, for the strings (labels) passed back to user space, is there any
documentation for suggested values for these strings?  Even though we
can't be completely type-safe, if there were suggested values in
a comment in the code, it could help a great deal for any code trying to
parse them for multiple different drivers/nics.


Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
