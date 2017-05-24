From: =?UTF-8?Q?Lars_Erik_Storbuk=C3=A5s?= <storbukas.dev@gmail.com>
Subject: Process phantom ECN event in TCP without CWR response
Date: Wed, 24 May 2017 10:45:01 +0200
Message-ID: <CAF0XkCAFchar70B=b+TNXOD+jDoxGy6Ty9N4qhBP6ji9yipwDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:37652 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939098AbdEXIpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 04:45:02 -0400
Received: by mail-it0-f47.google.com with SMTP id g126so34935745ith.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 01:45:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to generate phantom ECN events to (manually) decrease the
transmission rate/throughput.

The signals is meant to be generated and received on a single host. I
don't want the ECN event to generate a CWR (Congestion Window Reduced)
response to the sender. I'm trying to think of ways to avoid the TCP
code from entering the part of an ECN event, where the response to the
sender is generated.

I have thought of two (possible) solutions:

1. Before the phantom ECN signal is generated, a FLAG is set,
indicating that a phantom ECN event is coming. Before entering the
part where the CWR response is generated, perform a check on whether
the FLAG is set or not (if set - do not enter CWR part).

2. Instead of generating ECN signals (modify incoming packets), use a
flag to indicate that the next incoming ACK is processed as if it were
an ECN signal (except entering the CWR part).


Any input on how to implement, or pointers for where to look for
similar solutions is greatly appreciated.

...

For those who are interested in why I'm trying to achieve this:

I'm working on the implementation of a Deadline Aware, Less than Best
Effort framework. A framework for adding both LBE behaviour and
awareness of =E2=80=9Csoft=E2=80=9D delivery deadlines to any congestion co=
ntrol (CC)
algorithm, whether loss-based, delay- based or explicit
signaling-based. This effectively allows it to turn an arbitrary CC
protocol into a scavenger protocol that dynamically adapts its sending
rate to network conditions and remaining time before the deadline, to
balance timeliness and transmission aggressiveness.

/ Lars Erik Storbuk=C3=A5s (storbukas.dev@gmail.com)
