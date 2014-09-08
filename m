From: Ani Sinha <ani@arista.com>
Subject: Re: [PATCH] net: socket: do not validate msg_namelen unless msg_name
 is non-NULL
Date: Mon, 8 Sep 2014 14:53:20 -0700
Message-ID: <CAOxq_8Mu4BUZXFtokgU_a37X_813cUSzdYvWYyH95q2vrf0C8A@mail.gmail.com>
References: <CAOxq_8O=8epuyj2+V8RFep2tHVwk06q5gEK1ho0RUSV4GQV0Kw@mail.gmail.com>
 <1409951660.1177372.164202273.1FB2783A@webmail.messagingengine.com>
 <CAOxq_8NSGeeJYZP-5Pau+ehhnzrywYJ0Qr4fqrVD3cwQT-2eZQ@mail.gmail.com>
 <1409952419.5306.29.camel@localhost> <CAOxq_8Nvox3ABUoZFzmvMyb4XwAHx1YdTPfx9rpKAofM7crq=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"matthew.leach" <matthew.leach@arm.com>, netdev@vger.kernel.org,
	fenner <fenner@arista.com>, fruggeri <fruggeri@arista.com>,
	travisb <travisb@arista.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:53787 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254AbaIHVxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:53:41 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so3552670igb.15
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 14:53:40 -0700 (PDT)
In-Reply-To: <CAOxq_8Nvox3ABUoZFzmvMyb4XwAHx1YdTPfx9rpKAofM7crq=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just resent this patch again with git send-email so that it can be
directly applied without any whitespace damage.

Subject: [PATCH 1/1] net:socket: set msg_namelen to 0 if msg_name is
passed as NULL in msghdr struct from userland.

thanks,
ani

On Fri, Sep 5, 2014 at 2:44 PM, Ani Sinha <ani@arista.com> wrote:
> On Fri, Sep 5, 2014 at 2:26 PM, Hannes Frederic Sowa
>> If you set msg_namelen = 0 if msg_name == NULL prior to the < 0 check it
>> should not trigger the return -EINVAL and also we don't run into the
>> unsafe implicit conversion case when comparing msg_namelen with the
>> result of the sizeof(). Do you see any problems with that?
>
> yes, sorry I misunderstood you. Here's the updated patch :
>
> From ea39174d4475d7def61410210613ab24a4ce0e81 Mon Sep 17 00:00:00 2001
> From: Ani Sinha <ani@aristanetworks.com>
> Date: Fri, 5 Sep 2014 14:33:20 -0700
> Subject: [PATCH] net:socket: set msg_namelen to 0 if msg_name is
> passed as NULL in msghdr struct from userland.
>
> Linux manpage for recvmsg and sendmsg calls does not explicitly
> mention setting msg_namelen to 0 when
> msg_name passed set as NULL. When developers don't set msg_namelen
> member in msghdr, it might contain garbage
> value which will fail the validation check and sendmsg and recvmsg
> calls from kernel will return EINVAL. This will
> break old binaries and any code for which there is no access to source code.
> To fix this, we set msg_namelen to 0 when msg_name is passed as NULL
> from userland.
>
> Signed-off-by: Ani Sinha <ani@aristanetworks.com>
> ---
>  net/socket.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/net/socket.c b/net/socket.c
> index 95ee7d8..457be6a 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1997,6 +1997,9 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
>   if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
>   return -EFAULT;
>
> + if (kmsg->msg_name == NULL)
> + kmsg->msg_namelen = 0;
> +
>   if (kmsg->msg_namelen < 0)
>   return -EINVAL;
>
> --
> 1.7.4.4
