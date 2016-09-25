From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: pkt_cls: change tc actions order to
 be as the user sets
Date: Sun, 25 Sep 2016 10:39:03 -0400
Message-ID: <19723e0f-50b0-77fa-2884-c5bb6e182df9@mojatatu.com>
References: <1474812524-29089-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34112 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034180AbcIYOjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 10:39:06 -0400
Received: by mail-io0-f179.google.com with SMTP id e66so70413468iod.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 07:39:06 -0700 (PDT)
In-Reply-To: <1474812524-29089-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-25 10:08 AM, Hadar Hen Zion wrote:
> Currently the created tc actions list is reversed against the order
> set by the user.
> Change the actions list order to be the same as was set by the user.
>


Did something break? It seems to matter most for dumping. But even that
didnt breaking. Looking at the latest net tree, i tried:

====
sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 u32 \
match ip protocol 1 0xff flowid 1:2 \
action skbedit prio 33 \
action ife encode type 0xDEAD \
use mark 12 allow prio dst 02:15:15:15:15:15

Then I dump:
=====
jhs@jhs-foobar:~$ sudo $TC -s filter ls dev $ETH parent 1: protocol ip
filter pref 10 u32
filter pref 10 u32 fh 800: ht divisor 1
filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:2 
(rule hit 12 success 2)
   match 00010000/00ff0000 at 8 (success 2 )
	action order 1:  skbedit priority :33
	 index 2 ref 1 bind 1 installed 604 sec used first 589 sec last 583 sec
  	Action statistics:
	Sent 196 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

	action order 2: ife encode action pipe type 0xDEAD
	 use mark 12 allow prio dst 02:15:15:15:15:15
	 index 2 ref 1 bind 1 installed 604 sec used first 589 sec last 583 sec
	Action statistics:
	Sent 196 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

-----

cheers,
jamal
