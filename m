From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH net v2 1/1] net: tcp: Permit user set TCP_MAXSEG to
 default value
Date: Tue, 21 Mar 2017 09:27:36 +0800
Message-ID: <CA+6hz4o-kJ=xxWmwXPcY=+PvHvPQadTHXyDaZfhdtSVvpjUsSA@mail.gmail.com>
References: <1490057105-7068-1-git-send-email-fgao@ikuai8.com> <CADVnQy=8DK3B7HriNXums=NLEehkC9aCLK_uMpE7QmJLP6rNWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33863 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754788AbdCUB1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 21:27:38 -0400
Received: by mail-pg0-f67.google.com with SMTP id b5so22746358pgg.1
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 18:27:37 -0700 (PDT)
In-Reply-To: <CADVnQy=8DK3B7HriNXums=NLEehkC9aCLK_uMpE7QmJLP6rNWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 21, 2017 at 9:23 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Mon, Mar 20, 2017 at 8:45 PM, <fgao@ikuai8.com> wrote:
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index 1e319a5..4f7f163 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -2470,7 +2470,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>>                 /* Values greater than interface MTU won't take effect. However
>>                  * at the point when this call is done we typically don't yet
>>                  * know which interface is going to be used */
>> -               if (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW) {
>> +               if (!val && (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW)) {
>>                         err = -EINVAL;
>>                         break;
>
> I believe the sense of the val check is flipped in the proposed patch.
>
> I believe Eric suggested:
>
>   if (val && (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW)) {
>
> Has this been tested?
>
> neal

Sorry, I missed the test this time because of the minor fix.
As a result, wrote the wrong logic.

Regards
Feng
