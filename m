From: Adam Katz <adamkatz0@gmail.com>
Subject: libpcap and tc filters
Date: Sun, 3 Jul 2011 15:49:59 +0300
Message-ID: <CAA0qwj7qG7pyn4V+DVTzN7iPTnwGRJHQOdaDxiMkzrE=0AA5AA@mail.gmail.com>
References: <CAA0qwj5Ktxi=v3XDAdTpKS_pWa+HjFL5XcN2qsK5m57JJ5G2Bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:55134 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab1GCMuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2011 08:50:00 -0400
Received: by iwn6 with SMTP id 6so3848123iwn.19
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2011 05:49:59 -0700 (PDT)
In-Reply-To: <CAA0qwj5Ktxi=v3XDAdTpKS_pWa+HjFL5XcN2qsK5m57JJ5G2Bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Everyone!

I'm attempting to use tc to shape traffic sent using libpcap (more
precisely tcpreplay, based on libpcap). I'm doing this for a research
project.

Ii have a prio scheduler with a default band 2:

tc qdisc add dev eth0 root handle 1: prio priomap 2 2 2 2 2 2 2 2 2 2
2 2 2 2 2 2

with two filters attached to it:

tc filter add dev eth0 protocol ip parent 1: prio 1 u32 match ip dport
80 0xffff flowid 1:1
tc filter add dev eth0 protocol ip parent 1: prio 2 u32 match ip dport
443 0xffff flowid 1:2

(disregard the port numbers, they're here just as an example)

When sending actual traffic, the filters work and I see the
appropriate traffic entering the right class. BUT when replaying
captured traffic (with the appropriate port numbers) over eth0 using
tcpreplay, all packets end up in the default band 2 as if the filters
simply refuse to work.

Can anyone suggest a solution?

Thanks!
