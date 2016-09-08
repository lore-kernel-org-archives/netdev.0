From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: hold the transport before using it in sctp_hash_cmp
Date: Thu, 8 Sep 2016 21:17:26 +0800
Message-ID: <CADvbK_f8EUUCQcF67jer7fgH=7dS=hm7dpbyckxmv0UWiPZgAQ@mail.gmail.com>
References: <f71c2e03ae6e9b956f41c73fff5a282c86d79daf.1473328144.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00F7710@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34732 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933951AbcIHNR2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 09:17:28 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB00F7710@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Now sctp uses the transport without holding it in sctp_hash_cmp,
>> it can cause a use-after-free panic. As after it get transport from
>> hashtable, another CPU may free it, then the members it accesses
>> may be unavailable memory.
>
> How old is this bug?
I think since:
$ git describe 33c1529
v4.4-rc7-1158-g33c1529

> Is it in any release kernels?
>
yes

it was found in s390x, we could not reproduce it in x86_64 by now.
Maybe it needs low configuration cpu to reproduce.
