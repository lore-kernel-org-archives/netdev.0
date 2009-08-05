From: Michele BOLOGNA <michele.bologna@gmail.com>
Subject: strange behaviour in ping when specifying timeout in msec
Date: Wed, 5 Aug 2009 16:27:14 -0700
Message-ID: <13b17b8a0908051627n32ce7461j75e8459a2c54909c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:63919 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbZHEX1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 19:27:15 -0400
Received: by qw-out-2122.google.com with SMTP id 8so198167qwh.37
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2009 16:27:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Mr. Yoshifuji,
I recently noticed a strange behaviour in ping from iputils.

First of all some information:
mbologna@neptune:~$ ping -V
ping utility, iputils-sss20071127

Now, I want to specify a timeout and after it expires I would like
that ping exits, regardless of the packets received, so I use the -W
option:

      -W timeout
              Time to wait for a response, in seconds. The option affects only
              timeout in absense of any responses, otherwise  ping  waits  for
              two RTTs.

So, if I decide to wait 1s for 5 packets, the ping works fine and
exits after 5s:

mbologna@neptune:~$ ping -c 5 -W 1 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.

--- 1.1.1.1 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 3999ms

However, if I want to specify a timeout that is less than 1s, the ping
does not exit after 5*0.5 s and keeps staying active (notice the ^C):

mbologna@neptune:~$ ping -c 5 -W 0.5 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
^C
--- 1.1.1.1 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 3999ms

I also tried escaping the timeout with \ '' "" and so on, with no luck.
In a few words, is possible to specify a timeout that is less than 1 s?
Where am I wrong?

Thank you very much for your answer.
Best regards,
  Michele Bologna

-- 
Michele BOLOGNA
Email/GTalk: michele.bologna@gmail.com
Skype: michele-mb
PGP: 0x0BA55536
Web: www.mb.netsons.org
