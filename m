From: Mike_Phillips@URSCorp.com
Subject: Re: [PATCH] (5/6) ibmtr -- probe2
Date: Thu, 16 Oct 2003 15:52:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFF934C8CA.6C5807E0-ON88256DC1.007CA7CB-88256DC1.007DB00E@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> typedef struct ibmtr_dev_t {
> +    struct tok_info         ti;         /* must be first! */

Why must this be first ?? Sounds like an alignment issue, we shouldn't
assume some is aligned correctly just because it's the first entry.

>+           if (err)
>+                       goto out1;
>+
>+           return 0;
>+ out1:

Replace with:
            if (!err) return 0;
instead of the extra lines of code.

There also a patch of code at the end that changes stuff from dev_ibmtr[i]
to dev and then sets dev_ibmtr[i] = dev. Is there a really good reason for
this. I can't see any real reason for the change.

A small note for some of the reasoning behind the strangeness of the
probing. T/R ISA devices typically live on port A20, some old legacy system
only have 23 bit, not 24 bit addressing here and an automatic probe on A20
will conflict with anything on 220 (ie soundcard) and lock the machine
solid. Hence the ability to absolutely specify the port to be probed. (The
probing years ago used to be really, really simple, you just probed A20 and
A24 and saw if the card was there)

Mike
