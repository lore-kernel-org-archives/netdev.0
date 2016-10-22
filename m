From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] flow_dissector: avoid uninitialized variable access
Date: Sat, 22 Oct 2016 08:55:48 +0200
Message-ID: <20161022065548.GA1625@nanopsycho.orion>
References: <20161021155626.4020344-1-arnd@arndb.de>
 <20161021163118.GA2155@nanopsycho.orion>
 <CA+55aFz2500WfbKXAx8s67wrm9=yVJu65TpLgN_ybYNv0VEOKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Tom Herbert <tom@herbertland.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@ikuai8.com>, Eric Garver <e@erig.me>,
        Amir Vadai <amir@vadai.me>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38215 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752134AbcJVGzx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 02:55:53 -0400
Received: by mail-wm0-f52.google.com with SMTP id c78so22376412wme.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 23:55:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+55aFz2500WfbKXAx8s67wrm9=yVJu65TpLgN_ybYNv0VEOKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 22, 2016 at 03:48:48AM CEST, torvalds@linux-foundation.org wrote:
>On Fri, Oct 21, 2016 at 9:31 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>
>> I don't see how vlan could be used uninitialized. But I understand that
>> this is impossible for gcc to track it. Please just use uninitialized_var()
>
>Actually, I think we should never use "uninitialized_var()" except
>possibly for arrays or structures that gcc can complain about.
>
>It's a horrible thing to use, in that it adds extra cruft to the
>source code, and then shuts up a compiler warning (even the _reliable_
>warnings from gcc).
>
>It's much better to just initialize the variable, and if gcc some day
>gets smarter and sees that it  is unnecessary and always overwritten,
>so much the better. The cost of initializing a single word is
>basically zero.

On the other hand, I would agrue that initializing a var to "some" value
that is never used might confuse the reader. He would naturally try to
understand the reason for that exact value in initialization.
