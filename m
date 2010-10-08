From: Steven Brudenell <steven.brudenell@gmail.com>
Subject: tbf/htb qdisc limitations
Date: Fri, 8 Oct 2010 16:58:36 -0400
Message-ID: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:34434 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759649Ab0JHU6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 16:58:37 -0400
Received: by qyk10 with SMTP id 10so1802037qyk.19
        for <netdev@vger.kernel.org>; Fri, 08 Oct 2010 13:58:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi folks,

i was disappointed recently to find that i can't set the "burst"
parameters very high on the tbf or htb qdiscs. the actual limit of the
burst parameters varies, according to the rate parameter. at the
relatively low rate i want to set, i want to have the burst parameter
be several gigabytes, but i'm actually limited to only a few
megabytes.

(motivation: a fully-automated way to stay inside the monthly transfer
limits imposed by many ISPs these days, without resorting to a
constant rate limit. for example, comcast limits its customers to
250GB/month, which is about 101KB/s; many cellular data plans in the
US limit to 5GB/month =~ 2KB/s).

i'll gladly code a patch, but i'd like the list's advice on whether
this is necessary, and a little bit about how to proceed:

1) what is the purpose of the "rate tables" used in these qdiscs --
why use them in favor of dividing bytes by time to compute a rate? i
assume the answer has something to do with restrictions on using
floating point math (maybe even integer division?) at different places
/ interruptability states in the kernel. maybe this is documented on
kernelnewbies somewhere but i couldn't find it.

2) is there an established procedure for versioning a netlink
interface? today the netlink interface for tbf and htb is horribly
implementation-coupled (the "burst" parameters need to be munged
according to the "rate" parameters and kernel tick rate). i think i
would need to change these interfaces in order to change the
accounting implementation in the corresponding qdisc. however, i
probably want to remain compatible with old userspace.

~steve
