From: Richard <tuxbox.guru@gmail.com>
Subject: IGMPv3 and IGMPv2 interoperability - LEAVE packets are not sent on
 v3->v2 fallback
Date: Fri, 22 Apr 2016 17:03:08 +0100
Message-ID: <CAKQROYWRSzdxdeF0Q4Nru6bbKBg8Ot1Uc7-3GmO8KnpNU2zx0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:32835 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbcDVQDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 12:03:10 -0400
Received: by mail-lf0-f54.google.com with SMTP id e190so82000746lfe.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 09:03:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I have noticed some weird behaviour on IGMPv2 and IGMPv3.   The short
if it is, I can JOIN a multicast group normally (defaulting to v3) -
this works nicely until a IGMPv2 device is discovered on my network.
After that point, the LEAVE command for the group does not go out on
the wire and my router does not stop sending the data.

Digging down, I can see in IGMP.C that v2 has a variable 'reporter'
that does not seem to be used on IGMPv3 - and since the JOIN was on
v3, this value is Zero. To get the messages going out, this variable
needs to be non-zero.

To reproduce,

Boot Linux
Join a Multicast group (Wrireshark will show the packet if you are sniffing)
Force to use IGMPv2 (using echo "2" /proc/ .. etc)
Leave Multicast Group

At the leave point, nothing is sent over the wire, and the
subscription is removed from the list. For an experiment, I set
im->reporter=1 in the _group_add() function in the case for IGMPv3;
and this did allow the message to be sent after a v3->v2 fallback on
LEAVE; but there seems to be quite a lot of differences and I am not
so sure about the timers still working.

Any hints would be appreciated.
Regards,
Richard
