From: Cong Wang <cwang@twopensource.com>
Subject: Can not remove FAILED neigh entry??
Date: Tue, 17 Jun 2014 16:12:28 -0700
Message-ID: <CAHA+R7MqbSNaegwwEiGwmgWKtE_ZkGy6-NoHzZJV2RMK5uiPbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:62404 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbaFQXM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 19:12:29 -0400
Received: by mail-qa0-f49.google.com with SMTP id w8so44027qac.8
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 16:12:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all


I am wondering if the following behavior is expected, I can't
manually delete or flush a neigh entry:

[root@localhost ~]# ip -s -s neigh show
192.168.122.1 dev eth0 lladdr 52:54:00:5e:f5:1e used 22/22/5 probes 4 STALE
[root@localhost ~]#
[root@localhost ~]# ip neigh del 192.168.122.1 dev eth0
[root@localhost ~]# ip -s -s neigh show
192.168.122.1 dev eth0  used 34/34/17 probes 4 FAILED
[root@localhost ~]# ip -s -s neigh flush all
Nothing to flush.
[root@localhost ~]# ip -s -s neigh show
192.168.122.1 dev eth0  used 42/42/26 probes 4 FAILED
[root@localhost ~]# sleep 60
[root@localhost ~]# ip -s -s neigh show
192.168.122.1 dev eth0  used 130/130/113 probes 4 FAILED

I thought it would timeout (gc_stale_time) after it becomes FAILED,
but apparently it is still there after a long time. If this is what we expect,
then what's the right way to remove an entry from a neigh table manually?


Thanks!
