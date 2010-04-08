From: Antonio Almeida <vexwek@gmail.com>
Subject: HTB - What's the minimal value for 'rate' parameter?
Date: Thu, 8 Apr 2010 12:07:10 +0100
Message-ID: <z2q298f5c051004080407r5dfb27fai74c5cf74d0048ca5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, jarkao2@gmail.com, kaber@trash.net,
	davem@davemloft.net, devik@cdi.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:3078 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758227Ab0DHLHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 07:07:12 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1899434fgg.1
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 04:07:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!
I've been using HTB for a while, and we've already sent some e-mails
each other when resolving HTB accuracy issue.
When using HTB, I realised that for some configurations the rate limit
doesn't work.
I suspect that the problem is the minimum value of rate parameter,
which I cant figure out what is.

I simple configuration that turns out to be wrong is as fallows: The
root (1:1) gets the link bandwidth configuration; the second (1:2) is
set to 4096Kbit; then I have two branches (1:10 and 1:11) with rate
1024Kbit and ceil 4096Kbit; and finally a leaf class in each branch
(1:111 below 1:11, and 1:101 below 1:10) with rate 8bit and ceil
4096Kbit, and the same priority.
I don't want to have sustained rate, and since I must configure 'rate'
parameter I decide to set it to 8bits - which is the minimal accepted
value. My cue goes for 'rate' parameter. If I set 'rate' parameter to
1Kbit for instance, the problem disappears and the shaping is done
perfectly.

So, I'm looking for help to find out if the problem is actually in
this parameter configuration or if it's just coincidence and I'll get
the same problem ahead :(
What's the minimal value for 'rate' parameter using HTB qdisc?

Here's the tc command output, using leaves rate set to 8bit:

# tc -s class list dev eth1
class htb 1:101 parent 1:10 leaf 101: prio 3 rate 8bit ceil 4096Kbit
burst 225b cburst 3655b
 Sent 42305702 bytes 27943 pkt (dropped 23031, overlimits 0 requeues 0)
 rate 4036Kbit 333pps backlog 0b 126p requeues 0
 lended: 27817 borrowed: 0 giants: 0
 tokens: 1250000000 ctokens: -39387

class htb 1:11 parent 1:2 rate 1024Kbit ceil 4096Kbit burst 2113b cburst 3655b
 Sent 42170956 bytes 27854 pkt (dropped 0, overlimits 0 requeues 0)
 rate 4035Kbit 333pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: -937499999 ctokens: -42881

class htb 1:10 parent 1:2 rate 1024Kbit ceil 4096Kbit burst 2113b cburst 3655b
 Sent 42114938 bytes 27817 pkt (dropped 0, overlimits 0 requeues 0)
 rate 4035Kbit 333pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: -937499999 ctokens: -39387

class htb 1:1 root rate 1000Mbit ceil 1000Mbit burst 503375b cburst 503375b
 Sent 84285894 bytes 55671 pkt (dropped 0, overlimits 0 requeues 0)
 rate 8071Kbit 666pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: 62750 ctokens: 62750

class htb 1:111 parent 1:11 leaf 111: prio 3 rate 8bit ceil 4096Kbit
burst 225b cburst 3655b
 Sent 42363234 bytes 27981 pkt (dropped 23064, overlimits 0 requeues 0)
 rate 4035Kbit 333pps backlog 0b 127p requeues 0
 lended: 27854 borrowed: 0 giants: 0
 tokens: 1250000000 ctokens: -42881

class htb 1:2 parent 1:1 rate 4096Kbit ceil 4096Kbit burst 3655b cburst 3655b
 Sent 84285894 bytes 55671 pkt (dropped 0, overlimits 0 requeues 0)
 rate 8071Kbit 666pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: -937499999 ctokens: -937499999

class sfq 111:16 parent 111:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 127p requeues 0
 allot 1514

class sfq 101:252 parent 101:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 126p requeues 0
 allot 1514


Regards
  Antonio Almeida
