From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: [fw filter]: Broken! fw mark based tc class selection not working
Date: Sat, 12 Sep 2015 03:54:25 +0530
Message-ID: <CAA5aLPgCqOXU3vw6moSvADuOc4Q_TM2iJLHjSH0O8NwYJJ1t7g@mail.gmail.com>
References: <CAA5aLPhvkEPpDhaxSNWnGHU2H0WmCaYhbo-fYKP8+Xzka3-q=g@mail.gmail.com>
	<CAHA+R7P5jTGBof-oObzJ0SidRr17fKLGjoMkk0-VYzuSLjawZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:34542 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125AbbIKWY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 18:24:26 -0400
Received: by obbda8 with SMTP id da8so71560434obb.1
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 15:24:26 -0700 (PDT)
In-Reply-To: <CAHA+R7P5jTGBof-oObzJ0SidRr17fKLGjoMkk0-VYzuSLjawZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no handle with fw filter. That's the whole point is. If
handle and class (flow id) is not specified, then whatever be the mark
on the packet, its automatically set as flowid. So if mark is 0x10003,
then this fw filter

tc filter add dev eth0 parent 1:0 protocol ip fw

will cause 0x10003 being set as classid I.e. 1:3.


tc qdisc add dev eth0 root handle 1: htb
tc class add dev eth0 parent 1: classid 1:a htb rate 1mbit
tc class add dev eth0 parent 1: classid 1:b htb rate 1mbit
tc class add dev eth0 parent 1: classid 1:c htb rate 1mbit
tc filter add dev eth0 parent 1:0 protocol ip fw

iptables -t mangle -I OUTPUT -o eth0 -p tcp -j MARK --set-mark 0x1000a
iptables -t mangle -I OUTPUT -o eth0 -p icmp -j MARK --set-mark 0x1000b
iptables -t mangle -I OUTPUT -o eth0 -p udp -j MARK --set-mark 0x1000c
