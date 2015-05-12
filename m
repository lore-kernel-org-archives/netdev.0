From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] about "ipv6: tcp: fix flowlabel value in ACK messages send
 from TIME_WAIT"
Date: Tue, 12 May 2015 06:47:09 -0700
Message-ID: <1431438429.566.79.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36670 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932851AbbELNrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 09:47:11 -0400
Received: by iebix4 with SMTP id ix4so1036110ieb.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 06:47:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florent 

make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/tcp_minisocks.o
...
net/ipv4/tcp_minisocks.c:303:46: warning: restricted __be32 degrades to integer

            tw->tw_flowlabel = np->flow_label >> 12;


np->flow_label is a __be32 (network byte order)

Not sure what is expected from this shift on a BE machine, I am guessing
this is not giving the expected result.

Thanks
