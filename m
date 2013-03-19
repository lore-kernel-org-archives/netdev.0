From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH net-next] packet: Fix compile error
Date: Wed, 20 Mar 2013 00:46:38 +0200
Message-ID: <CAEnQRZAVBqQ3Hz84YeyqHcKc9kS93TTQoz3H3ag2cTtQPYt68g@mail.gmail.com>
References: <1363730481-7168-1-git-send-email-dbaluta@ixiacom.com>
	<20130319.180722.1735800542274116990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: willemb@google.com, edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:35709 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932663Ab3CSWqk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 18:46:40 -0400
Received: by mail-we0-f169.google.com with SMTP id t11so874136wey.14
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 15:46:38 -0700 (PDT)
In-Reply-To: <20130319.180722.1735800542274116990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 12:07 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Daniel Baluta <dbaluta@ixiacom.com>
> Date: Wed, 20 Mar 2013 00:01:21 +0200
>
>> PACKET_FANOUT_ROLLOVER and PACKET_FANOUT_FLAG_ROLLOVER are not decla=
red in
>> <tree>/usr/include/linux/if_packet.h together with the other PACKET_=
=46ANOUT_* macros
>> as one would expect. This causes the following compilation error:
>> <snip>
>> psock_fanout.c: In function =91test_control_single=92:
>> psock_fanout.c:230:23: error: =91PACKET_FANOUT_ROLLOVER=92 undeclare=
d (first use in this function)
>> </snip>
>>
>> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
>
> No, in fact, all of these should be removed completely.
>
> They are provided by the header files under linux/usr/include which
> get created by the "make headers_install" rule.
>
> So you either need to run the "make headers_install" rule before
> building the tests, or install the updated headers under /usr/include
> on your test machine.
>
> I'll remove the defines from the test, thanks for pointing this
> out.

Sorry if I am missing something but I don't think it's necessary to
"make headers_install" because selftests compilaton target already
include -I../../../../usr/include/ that points to linux/usr/include.

Anyhow, this is not an issue :). The problem is that there is no defini=
tion
for PACKET_FANOUT_ROLLOVER or PACKET_FANOUT_FLAG_ROLLOVER,
and the compilation still fails:

$ make
gcc -Wall -I../../../../usr/include/ -o psock_fanout psock_fanout.c
psock_fanout.c: In function =91test_control_single=92:
psock_fanout.c:212:23: error: =91PACKET_FANOUT_ROLLOVER=92 undeclared
(first use in this function)

On your system where does PACKET_FANOUT_ROLLOVER gets defined?

thanks,
Daniel.
