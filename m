From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Wed, 5 Nov 2003 16:42:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF919647C5.E8CC7ED3-ON88256DD6.0003A8F5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@redhat.com, krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





> Hey, what if the dev refcount goes to zero before your dev_hold?

Actually, that is what I had written in my second mail.

> I would argue even running the loop once means some protocol is busted.

I have seen a message regarding ref count of 1, some delay and then the
rmmod works fine. So it
doesn't seem busted.

- KK



|---------+---------------------------->
|         |           Stephen Hemminger|
|         |           <shemminger@osdl.|
|         |           org>             |
|         |           Sent by:         |
|         |           netdev-bounce@oss|
|         |           .sgi.com         |
|         |                            |
|         |                            |
|         |           11/05/2003 04:30 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  |       To:       krkumar@us.ltcfwd.linux.ibm.com                                                                 |
  |       cc:       davem@redhat.com, netdev@oss.sgi.com                                                            |
  |       Subject:  Re: [PATCH] panic during unregister_netdevice()                                                 |
  |                                                                                                                 |
  >-----------------------------------------------------------------------------------------------------------------|





>
> diff -ruN linux-2.6.0-test9-bk9/net/core/dev.c
linux-2.6.0-test9-bk9.new/net/core/dev.c
> --- linux-2.6.0-test9-bk9/net/core/dev.c             2003-11-05
15:43:21.000000000 -0800
> +++ linux-2.6.0-test9-bk9.new/net/core/dev.c         2003-11-05
15:43:50.000000000 -0800
> @@ -2749,8 +2749,10 @@
>                                    rtnl_exlock();
>
>                                    /* Rebroadcast unregister notification
*/
> +                                  dev_hold(dev);
>                                    notifier_call_chain(&netdev_chain,
>
NETDEV_UNREGISTER, dev);
> +                                  dev_put(dev);
>
>                                    if
(test_bit(__LINK_STATE_LINKWATCH_PENDING,
>                                                     &dev->state)) {
>

Hey, what if the dev refcount goes to zero before your dev_hold?
Actually this repeated notifier looks like it wouldn't work anyway.
Why would a protocol drop it's reference when notified a second time?

I would argue even running the loop once means some protocol is busted.
