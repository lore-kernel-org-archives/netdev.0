From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: [PATCH -mm] __ratelimit rewrite
Date: Mon, 5 May 2008 13:18:30 +0800
Message-ID: <a8e1da0805042218l6fbacfd9sa139b00c3077895b@mail.gmail.com>
References: <20080504070738.GA11832@darkstar.te-china.tietoenator.com>
	 <1209912447.16966.42.camel@localhost>
	 <a8e1da0805041837q4a5264c6l7bc23dce1d3282fd@mail.gmail.com>
	 <1209954305.13011.1.camel@localhost>
	 <a8e1da0805041958k30c03e20r6dd88f4135d6e5fe@mail.gmail.com>
	 <1209955974.13011.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, paulmck@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David Miller" <davem@davemloft.net>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:43714 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247AbYEEFSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 01:18:31 -0400
Received: by yw-out-2324.google.com with SMTP id 9so375717ywe.1
        for <netdev@vger.kernel.org>; Sun, 04 May 2008 22:18:30 -0700 (PDT)
In-Reply-To: <1209955974.13011.10.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 5, 2008 at 10:52 AM, Joe Perches <joe@perches.com> wrote:
>
> On Mon, 2008-05-05 at 10:58 +0800, Dave Young wrote:
>  > On Mon, May 5, 2008 at 10:25 AM, Joe Perches <joe@perches.com> wrote:
>  > > On Mon, 2008-05-05 at 09:37 +0800, Dave Young wrote:
>  > >  > >  I think your changes should then be done in
>  > >  > >  printk.h not creating a new ratelimit.h.
>  > >  > IMO ratelimit is not just for printk use now, so a standalone head
>  > >  > file is necessary.
>  > >  What other uses would ratelimit have?
>  > ratelimit is a general function,  another user of it is
>  > WARN_ON_RATELIMIT in this patch. It could have other usage in future.
>
>  You put WARN_ON_RATELIMIT in bug.h right?
>  WARN_ON in bug.h is a printk

Yes, warn is indeed printk, but it's not equal to printk.

>
>  printk.h should #include <asm/bug.h>
>  kernel.h should not include that file.
>
>  What non print related function could be served by ratelimit?

You can do some other handling except printk in ratelimit logic.

After searching the code, I guess DCCP-Sync ratelimit can use this feature.
David, am I right?

BTW, most of printk_ratelimit users should use their own
ratelimit_state, maybe I should do the replace work as a patch series.
