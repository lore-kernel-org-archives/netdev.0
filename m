From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v4] net: mac802154: comparision issue of type cast, finding
 by EXTRA_CFLAGS=-W
Date: Thu, 25 Apr 2013 11:59:06 +0200
Message-ID: <5178FE6A.3050108@redhat.com>
References: <5175DFBC.7040000@asianux.com> <5175F7F7.7000703@asianux.com> <51766F74.2090007@asianux.com> <20130425.041044.768895561908042668.davem@davemloft.net> <5178ECA2.6020402@asianux.com> <5178F120.5030500@acn-group.ch> <5178FA0D.8060009@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Christophe Aeschlimann <c.aeschlimann@acn-group.ch>,
	sergei.shtylyov@cogentembedded.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755522Ab3DYJ7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 05:59:25 -0400
In-Reply-To: <5178FA0D.8060009@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2013 11:40 AM, Chen Gang wrote:
> Need change ~(u8)0 to 0xff, or in mac802154_wpan_xmit(), "u8 chan"
> will never == MAC802154_CHAN_NONE.
>
> The related warning:
>    net/mac802154/wpan.c:325:2: warning: comparison is always false
>    due to limited range of data type [-Wtype-limits]

Hm, do you really need to include this huge pile of code below into the
commit message?

Couldn't you make the commit message simpler resp. more compact, e.g.:

Change MAC802154_CHAN_NONE from ~(u8)0 to 0xff, otherwise the comparison
in mac802154_wpan_xmit() for ``chan == MAC802154_CHAN_NONE'' will not succeed.
This bug can be boiled down to ``u8 foo = 0xff; if (foo == ~(u8)0) [...]
else [...]'' where the condition will always take the else branch.

.... something like that maybe?

> The related unit test:
>    cc -Wall -O2 -o test test.c
>    ./test
>    will output 'different'
>
>    (after use '0xff' instead of '~(u8)0', it will output 'equal')
>
> -----------------------test code begin--------------------------------
>
> #include <stdio.h>
>
> typedef unsigned char u8;
>
> int main()
> {
> 	u8 uc = 0xff;
>
> 	if (uc == ~(u8)0)
> 		printf("\nequal\n");
> 	else
> 		printf("\ndifferent\n");
>
> 	return 0;
> }
>
> -----------------------test code end----------------------------------
>
>
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>   net/mac802154/mac802154.h | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
> index a4dcaf1..703c121 100644
> --- a/net/mac802154/mac802154.h
> +++ b/net/mac802154/mac802154.h
> @@ -90,7 +90,7 @@ struct mac802154_sub_if_data {
>
>   #define MAC802154_MAX_XMIT_ATTEMPTS	3
>
> -#define MAC802154_CHAN_NONE		(~(u8)0) /* No channel is assigned */
> +#define MAC802154_CHAN_NONE		0xff /* No channel is assigned */
>
>   extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
>   extern struct ieee802154_mlme_ops mac802154_mlme_wpan;
>
