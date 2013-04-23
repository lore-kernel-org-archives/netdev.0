From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 13:46:49 -0700
Message-ID: <1366750009.8964.9.camel@edumazet-glaptop>
References: <CA+FuTSf-jJc5D_2js1-ZZU8kcaizzuKHjc-BY_Bqqk-9kaU+MA@mail.gmail.com>
	 <1366742817-8480-1-git-send-email-willemb@google.com>
	 <1366744738.8964.6.camel@edumazet-glaptop>
	 <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:58724 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755216Ab3DWUqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 16:46:52 -0400
Received: by mail-pa0-f50.google.com with SMTP id bg4so727427pad.37
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 13:46:52 -0700 (PDT)
In-Reply-To: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 16:30 -0400, Willem de Bruijn wrote:
> On Tue, Apr 23, 2013 at 3:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> >> +write_unlock:
> >> +             synchronize_rcu();
> >
> > I believe you do not need this synchronize_rcu() call.
> 
> Because in this special case rcu_assign_pointer always replaces a
> NULL value, correct? Thanks again for the feedback! I rebased, reran
> the tests and will send v4 with these two changes (only).

Well, there is no assignment or freeing after the synchronize_rcu();

(mask is a local var only)

This looks as a leftover.
