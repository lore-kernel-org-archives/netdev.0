From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dev-alloc-name-by-check-name-existence.patch
Date: Sat, 24 May 2014 23:03:35 -0400 (EDT)
Message-ID: <20140524.230335.310083059499297121.davem@davemloft.net>
References: <1400968011-13023-1-git-send-email-crquan@gmail.com>
	<20140524.175727.1149146448761347899.davem@davemloft.net>
	<CAH5vBdKc09Oseb2P=K9X2xqzy4UYHtKW5UCS+9NV_EyYEKJxDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbaEYDDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 23:03:37 -0400
In-Reply-To: <CAH5vBdKc09Oseb2P=K9X2xqzy4UYHtKW5UCS+9NV_EyYEKJxDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: crquan <crquan@gmail.com>
Date: Sat, 24 May 2014 19:58:12 -0700

> On Sat, May 24, 2014 at 2:57 PM, David Miller <davem@davemloft.net> wrote:
>> The cost is iterating creating the string over and over again
>> and then doing the hash lookup each time.
> 
> The original code calls sscanf / snprintf / strncmp for each existing intf,
> new code is not creating the string, it calls snprintf only, and it won't call
> more than original times of snprintf, right? I think here it depends on
> hash lookup performance,

The bitmap scan is one call, and fast forwards the search to the first open
index.

So it's a bitmap scan plus _ONE_ string creation and hash lookup in the most
common case, even with thousands upon thousands of devices.

I'm not applying your patch, it's a regression.

If you disagree with me, show performance numbers supporting your argument.
