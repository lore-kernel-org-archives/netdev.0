From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH -net 0/2] bonding: fix arp_validate desync state & race
Date: Fri, 06 Sep 2013 22:10:58 +0200
Message-ID: <522A36D2.1080306@redhat.com>
References: <1378496518-16104-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, davem@davemloft.net, andy@greyhouse.net,
	mleitner@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035Ab3IFULW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 16:11:22 -0400
In-Reply-To: <1378496518-16104-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2013 09:41 PM, Nikolay Aleksandrov wrote:
> Hello all,
> These two patches aim to fix the possible de-sync state which the bond
> can enter if we have arp_validate without arp_interval or the other way
> around. They also fix a race condition between arp_validate setting and
> mode changing.
> 
> Patch 01 - fixes the race condition between store_arp_validate and bond
> mode change by using rtnl for sync
> Patch 02 - fixes the possible de-sync state by setting/unsetting recv_probe
> if arp_interval is set/unset and also if arp_validate is set/unset
> 
> Best regards,
>  Nikolay Aleksandrov
> 
> 
> Nikolay Aleksandrov (2):
>   bonding: fix store_arp_validate race with mode change
>   bonding: fix bond_arp_rcv setting and arp validate desync state
> 
>  drivers/net/bonding/bond_main.c  |  4 ++--
>  drivers/net/bonding/bond_sysfs.c | 31 +++++++++++++++++++++++++------
>  drivers/net/bonding/bonding.h    |  1 +
>  3 files changed, 28 insertions(+), 8 deletions(-)
> 
Ugh, self-nack I just noticed the mode check in store_arp_validate passes
if new_value is 0.

I'll wait some time to see if there isn't anything else and re-post.

Cheers,
 Nik
