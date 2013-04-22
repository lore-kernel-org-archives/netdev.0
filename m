From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Net: mac802154: comparing issue by type cast, finding
 by EXTRA_CFLAGS=-W
Date: Mon, 22 Apr 2013 18:09:09 +0400
Message-ID: <51754485.6040708@cogentembedded.com>
References: <5174DB87.3010908@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	David Miller <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:65252 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126Ab3DVOKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 10:10:23 -0400
Received: by mail-la0-f53.google.com with SMTP id eg20so1624068lab.40
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 07:10:21 -0700 (PDT)
In-Reply-To: <5174DB87.3010908@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 22-04-2013 10:41, Chen Gang wrote:

>    need change ~(u8)0 to 0xff,
>    or in mac802154_wpan_xmit(), "u8 chan" will never == MAC802154_CHAN_NONE

>    find it by "make EXTRA_CFLAGS=-W"
>      net/mac802154/wpan.c:325:2: warning: comparison is always false
>      due to limited range of data type [-Wtype-limits]

>    related unit test:
>      cc -Wall -O2 -o test test.c
>      ./test
>      will output 'different'

>      (after use '0xff' instead of '~(u8)0', it will output 'equal')

> -----------------------test code begin--------------------------------

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

> -----------------------test code end----------------------------------


> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>   net/mac802154/mac802154.h |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)

> diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
> index 5c9e021..c59309f 100644
> --- a/net/mac802154/mac802154.h
> +++ b/net/mac802154/mac802154.h
> @@ -88,7 +88,7 @@ struct mac802154_sub_if_data {
>
>   #define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, hw)
>
> -#define MAC802154_CHAN_NONE		(~(u8)0) /* No channel is assigned */
> +#define MAC802154_CHAN_NONE		(0xff) /* No channel is assigned */

    () not needed now.

WBR, Sergei
