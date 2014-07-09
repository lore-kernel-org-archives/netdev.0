From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] return the right retcode when add a unreachable route
Date: Tue, 08 Jul 2014 19:33:57 -0700 (PDT)
Message-ID: <20140708.193357.143714071345442602.davem@davemloft.net>
References: <1404644511-22112-1-git-send-email-lucien.xin@gmail.com>
	<CAHA+R7OgTOCASmT03H37KKobb6m0hs3amF7GNWLy=JRLW+2dew@mail.gmail.com>
	<CADvbK_fBvG9WSMRWifJRUr6p-OQsZJL+MXC8LdDSbTEW8uSS4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbaGICeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 22:34:00 -0400
In-Reply-To: <CADvbK_fBvG9WSMRWifJRUr6p-OQsZJL+MXC8LdDSbTEW8uSS4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lucien xin <lucien.xin@gmail.com>
Date: Wed, 9 Jul 2014 09:51:02 +0800

> On Wed, Jul 9, 2014 at 2:49 AM, Cong Wang <cwang@twopensource.com> wrote:
>> On Sun, Jul 6, 2014 at 4:01 AM, Xin Long <lucien.xin@gmail.com> wrote:
>>
>> This would potentially break user-space applications.
> 
> yes, you are right. if I only handle the -ESRCH , like:
> 
> -       return __fib_lookup(net, flp, res);
> +
> +       err = __fib_lookup(net, flp, res);
> +       if(err == -ESRCH)
> +               return -ENETUNREACH;
> +
> +       return err;
> 
> I think it will be ok, after all, it looks confused that err is *No
> such process* when add a route.

It doesn't matter, if applications want to work on all kernels they
will test whatever error code is being provided now.

Therefore, by changing it you will break those applications.
