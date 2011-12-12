From: Alessandro Salvatori <sandr8@gmail.com>
Subject: Re: vmxnet3 driver broken since 3.0?
Date: Sun, 11 Dec 2011 23:54:50 -0800
Message-ID: <CAJeBh4uCzUTFpQxf-rcXWkCUy9UEryiaz8akiDovLqU2C8WQEg@mail.gmail.com>
References: <CAJeBh4sXMVnZcLcjiMyvpPPoG3708CeaQ3hDj_g2s72Hv09N6g@mail.gmail.com>
 <loom.20111211T232956-373@post.gmane.org>
Reply-To: sandr8@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Zbigniew Luszpinski <zbiggy@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50024 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892Ab1LLHzX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 02:55:23 -0500
Received: by yenm11 with SMTP id m11so3493143yen.19
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2011 23:55:22 -0800 (PST)
In-Reply-To: <loom.20111211T232956-373@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I guess this is the change that was introduced in 3.0 and that breaks v=
mxnet3:

commit 55513fb4281464e97aa1ff2b9c906ca5aed917c5
Author: Tom Herbert <therbert@google.com>
Date:   Mon Oct 18 17:55:58 2010 +0000

    net: fail alloc_netdev_mq if queue count < 1

    In alloc_netdev_mq fail if requested queue_count < 1.

    Signed-off-by: Tom Herbert <therbert@google.com>
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 04972a4..f44d29a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5511,6 +5511,12 @@ struct net_device *alloc_netdev_mq(int
sizeof_priv, const char *name,

        BUG_ON(strlen(name) >=3D sizeof(dev->name));

+       if (queue_count < 1) {
+               pr_err("alloc_netdev: Unable to allocate device "
+                      "with zero queues.\n");
+               return NULL;
+       }
+
        alloc_size =3D sizeof(struct net_device);
        if (sizeof_priv) {
                /* ensure 32-byte alignment of private area */

thanks!
-Alessandro-
=A0Here i am, A young man,
=A0A crashing computer program,
=A0Here is a pen, write out my name...

(from: The Servant - Orchestra)



On Sun, Dec 11, 2011 at 14:38, Zbigniew Luszpinski <zbiggy@o2.pl> wrote=
:
> Alessandro Salvatori <sandr8 <at> gmail.com> writes:
>> haven't had a chance to try the one from the 3.2 release candidates =
yet.
>
> In 3.2-rc5 is still broken. Exactly the same error you get. :(
> Someone introduced a change since kernel 3.0 which broke vmxnet3 driv=
er. And
> this breaking change continues in kernel 3.1 and 3.2-rc5 so it seems =
it will not
> go away. :(
>
> have a nice day,
> Zbigniew Luszpinski
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
