From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH 2/2] netlink: Diag core and basic socket info dumping
Date: Thu, 21 Mar 2013 18:31:19 +0400
Message-ID: <20130321143119.GA14763@paralelels.com>
References: <1363857669-19990-1-git-send-email-avagin@openvz.org>
 <1363857669-19990-3-git-send-email-avagin@openvz.org>
 <20130321125230.GB9046@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: Andrey Vagin <avagin@openvz.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:45504 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932539Ab3CUOdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 10:33:00 -0400
Content-Disposition: inline
In-Reply-To: <20130321125230.GB9046@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 12:52:30PM +0000, Thomas Graf wrote:
> On 03/21/13 at 01:21pm, Andrey Vagin wrote:
> > diff --git a/include/uapi/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
> > new file mode 100644
> > index 0000000..9328866
> > --- /dev/null
> > +++ b/include/uapi/linux/netlink_diag.h
> > +enum {
> > +	NETLINK_DIAG_MEMINFO,
> > +	NETLINK_DIAG_GROUPS,
> > +
> > +	NETLINK_DIAG_MAX,
> > +};
> 
> Please follow the common pattern and define NETLINK_DIAG_MAX as
> NETLINK_DIAG_GROUPS like other by doing>
> 
> 	[...] 
>         __NETLINK_DIAG_MAX,
> };
>  
> #define NETLINK_DIAG_MAX (__NETLINK_DIAG_MAX - 1)
>  
> Everyone is used to do:
>  
>         struct nlattr *attrs[NETLINK_DIAG_MAX+1];
>          
>         nla_parse([...], NETLINK_DIAG_MAX, [...]
> 

Thank you for this issue. I sent the separate patch
"[PATCH] net: fix *_DIAG_MAX constants", because currently only
INET_DIAG_MAX is correct.

> In fact, the follow-up patch to ss is buggy because of this.
> UNIX_DIAG_MAX suffers from the same problem which is problem the
> cause for this.

The code in ss looks like you described:
        struct rtattr *tb[UNIX_DIAG_MAX+1];
...
        parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
                     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));


        struct rtattr *tb[NETLINK_DIAG_MAX+1];
...
        parse_rtattr(tb, NETLINK_DIAG_MAX, (struct rtattr*)(r+1),
                     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)))

I think I should only update headers... Or I don't understand something.
