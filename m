From: jamal <hadi@cyberus.ca>
Subject: Re: netlink sockets and rtm_newlink messages
Date: Sun, 29 Sep 2002 11:09:10 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209291105410.8253-100000@shell.cyberus.ca>
References: <200209271555.TAA21348@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Patrick R. McManus" <mcmanus@ducksong.COM>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200209271555.TAA21348@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Alexey,
So that you dont forget, heres the patch:

---------------------------------------------------
--- net/core/rtnetlink.c        2002/09/29 10:41:08     1.1
+++ net/core/rtnetlink.c        2002/09/29 10:41:58
@@ -496,7 +496,6 @@
                break;
        case NETDEV_UP:
        case NETDEV_DOWN:
-               rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
                break;
        case NETDEV_CHANGE:
        case NETDEV_GOING_DOWN:
------------------

Wouldnt that spot be the best for NETDEV_UP/DOWN since thats the notifier
callback?
Also, can you remind me what if_change was for? netcarrier events?

cheers,
jamal

On Fri, 27 Sep 2002 kuznet@ms2.inr.ac.ru wrote:

> Hello!
>
> > the messages weren't identical
>
> One of them is a mud. Apparently, I forgot to delete the line
> rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING)
> in rtnetlink_event().
>
> Alexey
>
>
>
