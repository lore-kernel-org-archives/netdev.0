From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/6] flow_dissector: Add hash_extra field to
 flow_keys struct
Date: Fri, 27 Feb 2015 23:37:34 -0800
Message-ID: <1425109054.5130.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
	 <1425093109-1077-4-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:43783 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbbB1Hhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 02:37:36 -0500
Received: by iebtr6 with SMTP id tr6so36498143ieb.10
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 23:37:36 -0800 (PST)
In-Reply-To: <1425093109-1077-4-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 19:11 -0800, Tom Herbert wrote:

> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index c605d30..d41a034 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -252,7 +252,7 @@ struct qdisc_skb_cb {
>  	unsigned int		pkt_len;
>  	u16			slave_dev_queue_mapping;
>  	u16			_pad;
> -#define QDISC_CB_PRIV_LEN 20
> +#define QDISC_CB_PRIV_LEN 24
>  	unsigned char		data[QDISC_CB_PRIV_LEN];
>  };
> =20

This change breaks kernel build : We already are at the cb[] limit.

Please check commit 257117862634d89de33fec74858b1a0ba5ab444b
("net: sched: shrink struct qdisc_skb_cb to 28 bytes")


                 from drivers/infiniband/ulp/ipoib/ipoib_main.c:35:
In function =E2=80=98ipoib_skb_cb=E2=80=99,
    inlined from =E2=80=98ipoib_hard_header=E2=80=99 at drivers/infinib=
and/ulp/ipoib/ipoib_main.c:816:19:
include/linux/compiler.h:424:20: error: call to =E2=80=98__compiletime_=
assert_136=E2=80=99 declared with attribute error: BUILD_BUG_ON failed:=
 sizeof(skb->cb) < sizeof(struct ipoib_cb)
    prefix ## suffix();    \
                    ^
include/linux/compiler.h:429:2: note: in expansion of macro =E2=80=98__=
compiletime_assert=E2=80=99
  __compiletime_assert(condition, msg, prefix, suffix)
  ^
include/linux/compiler.h:441:2: note: in expansion of macro =E2=80=98_c=
ompiletime_assert=E2=80=99
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
  ^
include/linux/bug.h:50:37: note: in expansion of macro =E2=80=98compile=
time_assert=E2=80=99
 #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                     ^
include/linux/bug.h:74:2: note: in expansion of macro =E2=80=98BUILD_BU=
G_ON_MSG=E2=80=99
  BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
  ^
drivers/infiniband/ulp/ipoib/ipoib.h:136:2: note: in expansion of macro=
 =E2=80=98BUILD_BUG_ON=E2=80=99
  BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct ipoib_cb));
  ^
  CC      drivers/parport/ieee1284.o
  CC      drivers/net/arcnet/arc-rawmode.o
  CC      drivers/misc/c2port/core.o
  CC      drivers/mfd/rtsx_pcr.o
In function =E2=80=98ipoib_skb_cb=E2=80=99,
    inlined from =E2=80=98ipoib_start_xmit=E2=80=99 at drivers/infiniba=
nd/ulp/ipoib/ipoib_main.c:719:19:
include/linux/compiler.h:424:20: error: call to =E2=80=98__compiletime_=
assert_136=E2=80=99 declared with attribute error: BUILD_BUG_ON failed:=
 sizeof(skb->cb) < sizeof(struct ipoib_cb)
    prefix ## suffix();    \
                    ^
include/linux/compiler.h:429:2: note: in expansion of macro =E2=80=98__=
compiletime_assert=E2=80=99
  __compiletime_assert(condition, msg, prefix, suffix)
  ^
include/linux/compiler.h:441:2: note: in expansion of macro =E2=80=98_c=
ompiletime_assert=E2=80=99
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
  ^
include/linux/bug.h:50:37: note: in expansion of macro =E2=80=98compile=
time_assert=E2=80=99
 #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                     ^
include/linux/bug.h:74:2: note: in expansion of macro =E2=80=98BUILD_BU=
G_ON_MSG=E2=80=99
  BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
  ^
drivers/infiniband/ulp/ipoib/ipoib.h:136:2: note: in expansion of macro=
 =E2=80=98BUILD_BUG_ON=E2=80=99
  BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct ipoib_cb));
  ^
make[4]: *** [drivers/infiniband/ulp/ipoib/ipoib_main.o] Error 1
make[3]: *** [drivers/infiniband/ulp/ipoib] Error 2
make[2]: *** [drivers/infiniband/ulp] Error 2
make[1]: *** [drivers/infiniband] Error 2
make[1]: *** Waiting for unfinished jobs....
