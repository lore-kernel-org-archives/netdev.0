From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net 4/4] sctp: fix some type cast warnings introduced
 since very beginning
Date: Mon, 30 Oct 2017 23:17:39 +0800
Message-ID: <CADvbK_ePXHxu71MZPrHRsDqS0yKtwUv4OGy3u0-caq4UHjBOcA@mail.gmail.com>
References: <cover.1509190967.git.lucien.xin@gmail.com> <40b05aa84d107b434bae3794692ac2da61da65ca.1509190967.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD00A8AA8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:57096 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752492AbdJ3PRk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 11:17:40 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00A8AA8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 7:12 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Xin Long
>> Sent: 28 October 2017 12:44
>> These warnings were found by running 'make C=2 M=net/sctp/'.
>> They are there since very beginning.
> ...
>> -             param.crr_id = i;
>> +             param.crr_id = htonl(i);
> ...
>
> Isn't this a bug fix, not just removing a warning??
It's actually fiine,
crr_id is just an identifier, and receiver will only pack the same value to the
asconf_ack chunk, and then sender checks with:
if (asconf_ack_param->crr_id == asconf_param->crr_id)
...

So no issue could be caused by this, I didn't count it as a bug.
