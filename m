From: Iain Hibbert <plunky-+vE1BRBCC0GuOtvtkYNheg@public.gmane.org>
Subject: Re: Expected behavior of shutdown() in multi-threaded socket
 programming
Date: Fri, 12 Jun 2009 09:46:05 +0100 (BST)
Message-ID: <1244796365.448636.603.nullmailer@galant.ukfsn.org>
References: <35c90d960905191429x1c3b6104qca2a672d50f0364c@mail.gmail.com> <35c90d960906111724w4794b40aw1c51d64586ecaeb6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Nick Pelly <npelly-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <35c90d960906111724w4794b40aw1c51d64586ecaeb6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Jun 2009, Nick Pelly wrote:

> Any comments on this one? I would like to correct the behavior of
> shutdown() on AF_BLUETOOTH sockets, but I have been advised by Marcel
> Holtmann that we need to agree on the correct behavior first.
>
> How should shutdown() behave when other threads are blocked on the same socket?

IMHO consistency should apply.

The opengroup specification for shutdown() says

  "The shutdown() function shall cause all or part of a full-duplex
  connection on the socket associated with the file descriptor socket to
  be shut down."

and while that does not really cover the case when the socket is blocked
in accept(), if all the other socket types abort the block then that is
what the PF_BLUETOOTH sockets should do too.

The opengroup specification for accept() suggests EINVAL would be returned
if the socket was not accepting connections and arguably that is the case
after a shutdown(), though ECONNABORTED could be used too (your program
displays ECONNABORTED on NetBSD for instance)

> I also have similar results for other blocking syscalls such as
> connect(), read(), write(), poll() etc, but the test program is not as
> simple.

They should all handle the shutdown().

iain
