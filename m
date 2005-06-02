From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload feature
Date: Thu, 2 Jun 2005 16:18:55 -0700
Message-ID: <003201c567c9$73322240$3910100a@pc.s2io.com>
References: <20050527.120215.26278001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
        <raghavendra.koushik@neterion.com>, <leonid.grossman@neterion.com>,
        <ananda.raju@neterion.com>, <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20050527.120215.26278001.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David,
Since there seems to be pros and cons for both the approaches, we are
planning
to submit two separate patches(one for each approach). These patches also
include the ethtool changes. In terms of performance, we did not observe any
diff between the two approaches although the first approach(using SG)
minimizes
coalescing in driver.

Also, some changes will be required in the ethtool user-level utility.
I'm not sure if this is the right forum to submit patches for the ethtool
utility as well..

Thanks,
Ravi


-----Original Message-----
From: David S. Miller [mailto:davem@davemloft.net]
Sent: Friday, May 27, 2005 12:02 PM
To: ravinandan.arakali@neterion.com
Cc: jgarzik@pobox.com; netdev@oss.sgi.com;
raghavendra.koushik@neterion.com; leonid.grossman@neterion.com;
ananda.raju@neterion.com; rapuru.sriram@neterion.com
Subject: Re: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload
feature


From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Date: Fri, 27 May 2005 09:32:00 -0700

> Thanks for the quick feedback.
> At that time when we considered using skb_shinfo(skb)->fraglist,
> it contained fragments of MTU size. So, for a 60k udp datagram
> and 1500 MTU we will have 60k/1500 = 45 fragments which is
> more than MAX_SKB_FRAGS(18).
>
> However we will relook at fraglist for the possibility of increasing
> frag size to >MTU.

MAX_SKB_FRAGS controls the limit of skb_shinfo(skb)->frags[]
entries, not how many SKBs may be chained via
skb_shinfo(skb)->fraglist, there is no limit on the latter.

Note that there is much coalescing that can be performed on
the SKB list data areas, particularly if UDP sendfile() is
being used.

But such coalescing is messy to be performing inside of the
drivers.  It may end up being the case that your approach
ends up being a better one for these reasons.
