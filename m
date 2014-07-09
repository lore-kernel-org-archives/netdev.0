From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH] return the right retcode when add a unreachable route
Date: Wed, 9 Jul 2014 09:51:02 +0800
Message-ID: <CADvbK_fBvG9WSMRWifJRUr6p-OQsZJL+MXC8LdDSbTEW8uSS4w@mail.gmail.com>
References: <1404644511-22112-1-git-send-email-lucien.xin@gmail.com>
	<CAHA+R7OgTOCASmT03H37KKobb6m0hs3amF7GNWLy=JRLW+2dew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43833 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbaGIBvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 21:51:03 -0400
Received: by mail-wg0-f44.google.com with SMTP id k14so6723404wgh.27
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 18:51:02 -0700 (PDT)
In-Reply-To: <CAHA+R7OgTOCASmT03H37KKobb6m0hs3amF7GNWLy=JRLW+2dew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 9, 2014 at 2:49 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Sun, Jul 6, 2014 at 4:01 AM, Xin Long <lucien.xin@gmail.com> wrote:
>
> This would potentially break user-space applications.

yes, you are right. if I only handle the -ESRCH , like:

-       return __fib_lookup(net, flp, res);
+
+       err = __fib_lookup(net, flp, res);
+       if(err == -ESRCH)
+               return -ENETUNREACH;
+
+       return err;

I think it will be ok, after all, it looks confused that err is *No
such process* when add a route.

thanks for your reply.
