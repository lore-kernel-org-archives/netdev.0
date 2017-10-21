From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net 0/2] net: diag: fix a potential security issue
Date: Fri, 20 Oct 2017 23:18:04 -0700
Message-ID: <CANn89i+n=MMUDdjDm4SQfEfQvFM+PgSKCrtDzBY=OiwsiyvYMg@mail.gmail.com>
References: <cover.1508398111.git.lucien.xin@gmail.com> <20171021.022737.1906342496133825805.davem@davemloft.net>
 <CADvbK_fWmmC3ggpoT--Pxk3GxZ8Gq_rbdFGTuXk-BuTHTO=eXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:48172 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751104AbdJUGSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 02:18:06 -0400
Received: by mail-yw0-f194.google.com with SMTP id q1so8124295ywh.5
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 23:18:06 -0700 (PDT)
In-Reply-To: <CADvbK_fWmmC3ggpoT--Pxk3GxZ8Gq_rbdFGTuXk-BuTHTO=eXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 11:06 PM, Xin Long <lucien.xin@gmail.com> wrote:
>
>
> On Sat, Oct 21, 2017 at 9:27 AM, David Miller <davem@davemloft.net> wrote:
>>
>> From: Xin Long <lucien.xin@gmail.com>
>> Date: Thu, 19 Oct 2017 15:32:23 +0800
>>
>> > This patch is to void the potential security issue that the family
>> > or protocol modules are autoloaded when requesting _diag module by
>> > not requesting _diag module if the family or protocol is not added
>> > or registered in sock_diag and inet_diag.
>> >
>> > As the repost of the patch '[PATCH net] sock_diag: request _diag
>> > module only when the family or proto has been registered', this
>> > patchset fixes the compiling errors when INET is not set, and
>> > also split into two patches to make it clear to review.
>>
>> This makes no sense to me.
>>
>> Any user can just open a socket() in the appropriate protocol
>> family to cause the module to be loaded.
>>
>> If someone wants modules to not be loaded, block them using
>> traditional module loading infrastructure mechanisms.  Or
>> don't load the module at all.
>>
>> Sorry I am not applying this.
>
> Hi David,
>
> I'm still thinking it's not good after 'ss', sctp, dccp,
> af_packet ... are just loaded, in which case, no one actually
> open any socket with these family or proto.
>
> I talked with Marcelo before, one scenario as he said:
>
> Imagine a customer generates a sosreport on their system, and
> with that, it loads sctp module. From then on, if their firewall
> doesn't block incoming packets for sctp, they may be prone to some
> remotely triggerable issue on sctp code, without even actually using
> sctp.

For that reason, we have disabled autoloading of SCTP.
( removing the
 MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-132");
 MODULE_ALIAS("net-pf-" __stringify(PF_INET6) "-proto-132");
)
root must modprobe the module before it is accessible.

However inet_diag is a way to have the module loaded anyway.

This is why I like your patch Xin.

David is only saying that your patch alone is not enough to prevent a
user to use socket() to autoload SCTP.
