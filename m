From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: support global vtag assochash and per endpoint
 s(d)port assochash table
Date: Wed, 2 Sep 2015 04:03:22 +0800
Message-ID: <CADvbK_foLzSwH14u0rQo26y2Vi4aGW0rQDBHNJMD-S3fR1bJCg@mail.gmail.com>
References: <6d09d44f7972c5a5e458fc0eef98aa057896403d.1441043068.git.lucien.xin@gmail.com>
	<20150831.151600.1336251424367446992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33330 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbbIAUDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 16:03:22 -0400
Received: by oixx17 with SMTP id x17so6719849oix.0
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 13:03:22 -0700 (PDT)
In-Reply-To: <20150831.151600.1336251424367446992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 1, 2015 at 6:16 AM, David Miller <davem@davemloft.net> wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Tue,  1 Sep 2015 01:44:28 +0800
>
>> @@ -524,18 +524,16 @@ static inline int sctp_assoc_hashfn(struct net *net, __u16 lport, __u16 rport)
>>  {
>>       int h = (lport << 16) + rport + net_hash_mix(net);
>>       h ^= h>>8;
>> -     return h & (sctp_assoc_hashsize - 1);
>> +     return h & (256 - 1);
>
> It is not acceptable to use a magic constant for the hash table size.
> You need to define this using a macro and use it consistently.
>
> Furthermore, you should be looking into dynamically sized
> hash tables because not everyone will need this many entries.

okay, I will correct it, thanks
