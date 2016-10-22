From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] flow_dissector: avoid uninitialized variable access
Date: Fri, 21 Oct 2016 18:48:48 -0700
Message-ID: <CA+55aFz2500WfbKXAx8s67wrm9=yVJu65TpLgN_ybYNv0VEOKA@mail.gmail.com>
References: <20161021155626.4020344-1-arnd@arndb.de> <20161021163118.GA2155@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35368 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755854AbcJVBsu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 21:48:50 -0400
In-Reply-To: <20161021163118.GA2155@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 9:31 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>
> I don't see how vlan could be used uninitialized. But I understand that
> this is impossible for gcc to track it. Please just use uninitialized_var()

Actually, I think we should never use "uninitialized_var()" except
possibly for arrays or structures that gcc can complain about.

It's a horrible thing to use, in that it adds extra cruft to the
source code, and then shuts up a compiler warning (even the _reliable_
warnings from gcc).

It's much better to just initialize the variable, and if gcc some day
gets smarter and sees that it  is unnecessary and always overwritten,
so much the better. The cost of initializing a single word is
basically zero.

            Linus
