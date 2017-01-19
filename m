From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v7 10/13] net: ethernet: aquantia: Hardware interface and
 utility functions
Date: Thu, 19 Jan 2017 14:40:41 -0800
Message-ID: <d00b973a-e211-2b31-3725-d63c45406af6@gmail.com>
References: <cover.1484860589.git.vomlehn@texas.net>
 <4af27936d91148b266fee653fa49c47d23a0c9fa.1484860589.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36389 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753047AbdASWko (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:44 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so5150824pgf.3
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 14:40:44 -0800 (PST)
In-Reply-To: <4af27936d91148b266fee653fa49c47d23a0c9fa.1484860589.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2017 01:33 PM, Alexander Loktionov wrote:
> From: David VomLehn <vomlehn@texas.net>
> 
> Add functions to interface with the hardware and some utility functions.
> 
> Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
> Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
> Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
> Signed-off-by: David M. VomLehn <vomlehn@texas.net>
> ---

> +#ifndef AQ_HW_UTILS_H
> +#define AQ_HW_UTILS_H
> +
> +#include "aq_common.h"
> +
> +#ifndef HIDWORD
> +#define LODWORD(_qw)    ((u32)(_qw))
> +#define HIDWORD(_qw)    ((u32)(((_qw) >> 32) & 0xffffffff))
> +#endif

upper_32_bits() and lower_32_bits()?

> +
> +#define AQ_HW_SLEEP(_US_) mdelay(_US_)
> +
> +#define AQ_HW_WAIT_FOR(_B_, _US_, _N_) \
> +do { \
> +	unsigned int AQ_HW_WAIT_FOR_i; \
> +	for (AQ_HW_WAIT_FOR_i = _N_; (!(_B_)) && (AQ_HW_WAIT_FOR_i);\
> +	--AQ_HW_WAIT_FOR_i) {\
> +		udelay(_US_); \
> +	} \
> +	if (!AQ_HW_WAIT_FOR_i) {\
> +		err = ETIME; \
> +	} \
> +} while (0)

You might want to use readl_poll_timeout() or something similar, at the
very least this should be a function for which we can get proper type
checking.
-- 
Florian
