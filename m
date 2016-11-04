From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: assign assoc_id earlier in __sctp_connect
Date: Fri, 4 Nov 2016 18:45:26 +0800
Message-ID: <CADvbK_cy_FLHTu25utHwQCF4foY7_xGuCssO1qKLWs_4AXSCQg@mail.gmail.com>
References: <9df38dcd0323ad92386eb6851a60dc128dd00b4e.1478199530.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:33073 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760828AbcKDKp2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 06:45:28 -0400
In-Reply-To: <9df38dcd0323ad92386eb6851a60dc128dd00b4e.1478199530.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 4, 2016 at 3:03 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> sctp_wait_for_connect() currently already holds the asoc to keep it
> alive during the sleep, in case another thread release it. But Andrey
> Konovalov and Dmitry Vyukov reported an use-after-free in such
> situation.
>
> Problem is that __sctp_connect() doesn't get a ref on the asoc and will
> do a read on the asoc after calling sctp_wait_for_connect(), but by then
> another thread may have closed it and the _put on sctp_wait_for_connect
> will actually release it, causing the use-after-free.
>
> Fix is, instead of doing the read after waiting for the connect, do it
> before so, and avoid this issue as the socket is still locked by then.
> There should be no issue on returning the asoc id in case of failure as
> the application shouldn't trust on that number in such situations
> anyway.
>
> This issue doesn't exist in sctp_sendmsg() path.
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Reviewed-by: Xin Long <lucien.xin@gmail.com>
