From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: make netdev_for_each_lower_dev safe for device
 removal
Date: Wed, 17 Feb 2016 12:01:10 -0700
Message-ID: <56C4C376.2000400@cumulusnetworks.com>
References: <1455728431-21976-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33542 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030250AbcBQTBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 14:01:12 -0500
Received: by mail-ob0-f172.google.com with SMTP id jq7so29094146obb.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 11:01:12 -0800 (PST)
In-Reply-To: <1455728431-21976-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/17/16 10:00 AM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> When I used netdev_for_each_lower_dev in commit bad531623253 ("vrf:
> remove slave queue and private slave struct") I thought that it acts
> like netdev_for_each_lower_private and can be used to remove the current
> device from the list while walking, but unfortunately it acts more like
> netdev_for_each_lower_private_rcu and doesn't allow it. The difference
> is where the "iter" points to, right now it points to the current element
> and that makes it impossible to remove it. Change the logic to be
> similar to netdev_for_each_lower_private and make it point to the "next"
> element so we can safely delete the current one. VRF is the only such
> user right now, there's no change for the read-only users.
>

-----8<-----

>
> CC: David Ahern <dsa@cumulusnetworks.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> CC: Vlad Yasevich <vyasevic@redhat.com>
> Fixes: bad531623253 ("vrf: remove slave queue and private slave struct")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>   include/linux/netdevice.h | 2 +-
>   net/core/dev.c            | 4 ++--
>   2 files changed, 3 insertions(+), 3 deletions(-)

Solves the problem for me. Thanks for the quick turnaround, Nik.

Reviewed-by / Tested-by: David Ahern <dsa@cumulusnetworks.com>
