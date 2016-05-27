From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH net] ieee802154: fix logic error in
 ieee802154_llsec_parse_dev_addr
Date: Fri, 27 May 2016 12:24:23 +0200
Message-ID: <57482057.1070909@osg.samsung.com>
References: <7c36848d-28b5-87cc-f998-53cc2428a0a6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: Baozeng Ding <sploving1@gmail.com>, aar@pengutronix.de,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:54209 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbcE0KY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2016 06:24:27 -0400
In-Reply-To: <7c36848d-28b5-87cc-f998-53cc2428a0a6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26/05/16 15:07, Baozeng Ding wrote:
> Fix a logic error to avoid potential null pointer dereference.
>
> Signed-off-by: Baozeng Ding<sploving1@gmail.com>
> ---
>   net/ieee802154/nl802154.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
> index ca207db..116187b 100644
> --- a/net/ieee802154/nl802154.c
> +++ b/net/ieee802154/nl802154.c
> @@ -1289,8 +1289,8 @@ ieee802154_llsec_parse_dev_addr(struct nlattr *nla,
>   				     nl802154_dev_addr_policy))
>   		return -EINVAL;
>   
> -	if (!attrs[NL802154_DEV_ADDR_ATTR_PAN_ID] &&
> -	    !attrs[NL802154_DEV_ADDR_ATTR_MODE] &&
> +	if (!attrs[NL802154_DEV_ADDR_ATTR_PAN_ID] ||
> +	    !attrs[NL802154_DEV_ADDR_ATTR_MODE] ||
>   	    !(attrs[NL802154_DEV_ADDR_ATTR_SHORT] ||
>   	      attrs[NL802154_DEV_ADDR_ATTR_EXTENDED]))
>   		return -EINVAL;

Good catch!

Reviewed-by: Stefan Schmidt<stefan@osg.samsung.com>

regards
Stefan Schmidt
