From: kuznet@ms2.inr.ac.ru
Subject: Re: dev->destructor
Date: Thu, 1 May 2003 05:10:33 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305010110.FAA08689@sex.inr.ac.ru>
References: <20030429.232631.68131803.davem@redhat.com>
Mime-Version: 1.0
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030429.232631.68131803.davem@redhat.com> from "David S. Miller" at Apr 29, 3 11:26:31 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> 1) dev_get() gets module reference and dev_put() puts is.
>    Ugly, as this means dev_get() can fail, but this does
>    cover all the possible cases.

Seems, you eventually _really_ understood why I histerically moan
about bogosity of modules and maybe ready to recongnize that it is
not just histerical moaning in some part. :-)


> 2) Make unregister_netdev() wait for refcount to reach 1
>    regardless of whether dev->destructor is NULL or not.
> 
> I don't like #1.  Do you see some holes in #2?

It is deadlock.


> As Stephen brought up, this also means we should do something
> about that NETDEV_UNREGISTER code in dst_dev_event() :-(

It is just one and the simplest subcase of general situation.
Module must not be unloaded while device is held, that's all.
Also, it is not specific to netdevices. The same applies to each object
in the stack, which is under control of a module. You may like 1), you
may dislike it, but people who designed modules _really_ expect
we must use this idiotic module_get() each time when referencing some object.
Remember about sockets?

Well, my alternatives are:

0) To make module unloading right, rather then preserve creepy scheme.

3) To prohibit unloading such modules and live in peace with code not
   crippled with midule_get(). I hear, hear your growling, but I feel
   enough comfortable with this and you may fell better too after comparing
   to 1), which is exactly the way how all this queer engine was designed.

Alexey
