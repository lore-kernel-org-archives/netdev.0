From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2.6.20] ixgb: Use ARRAY_SIZE macro when appropriate
Date: Mon, 05 Feb 2007 12:31:26 -0800
Message-ID: <45C7941E.2050305@intel.com>
References: <20070205165429.GD3896@Ahmed> <20070205165933.GL3896@Ahmed> <20070205201804.GC11055@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, jeffrey.t.kirsher@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46191 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933306AbXBEUbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 15:31:49 -0500
In-Reply-To: <20070205201804.GC11055@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> On Mon, Feb 05, 2007 at 06:59:33PM +0200, Ahmed S. Darwish wrote:
>> A patch to use ARRAY_SIZE macro already defined in kernel.h.
> 
> Remove it and use ARRAY_SIZE instead.
> 
>> --- a/drivers/net/ixgb/ixgb_param.c
>> +++ b/drivers/net/ixgb/ixgb_param.c
>> @@ -245,7 +245,7 @@ ixgb_validate_option(int *value, struct ixgb_option *opt)
>>  	return -1;
>>  }
>>  
>> -#define LIST_LEN(l) (sizeof(l) / sizeof(l[0]))
>> +#define LIST_LEN(l) ARRAY_SIZE(l)

yes, well spotted. Please change line 338 in this file to read:

      .arg  = { .l = { .nr = ARRAY_SIZE(fc_list),

instead, so you can remove the LIST_LEN macro completely.

Thanks,

Auke
