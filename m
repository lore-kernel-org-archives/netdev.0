From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PROCFS] [NETNS] issue with /proc/net entries
Date: Thu, 10 Jan 2008 18:24:49 +0100
Message-ID: <478654E1.5050501@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42209 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254AbYAJRYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 12:24:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

While testing the current network namespace stuff merged in net-2.6.25,
I bumped into the following problem with the /proc/net/ entries.
It doesn't always display the actual data of the current namespace,
but sometime displays data from other namespaces.

I bisected the problem to the commit:
"proc: remove/Fix proc generic d_revalidate"
3790ee4bd86396558eedd86faac1052cb782e4e1

The problem: If a process in a particular network namespace changes
current directory to /proc/net, then processes in other network
namespaces trying to look at /proc/net entries will see data from the
first namespace (the one with CWD /proc/net). (See test case below).

As you comments in the commit suggest, you seem to be aware of some
issues when CONFIG_NET_NS=y. Is it one of these corner cases you
identified? Any idea on how we can fix it?

Thanks.

Benjamin


Test case:
----------
(1) Shell 1, in init namespace:
$ cat /proc/net/dev
lo ...
eth0 ...

(2) Shell 2, in another network namespace
$ cat /proc/net/dev
lo ...

(3) Shell 1
$ cd /proc/net
$ cat dev
lo ...
eth0 ...

(4) Shell 2
$ cat /proc/net/dev
lo ...
eth0 ...

Argh, lo + eth0 in child namespace.... the device list of init netns
is displayed in /proc/net/dev of child namespace :-(

(5) Shell 1
$ cd /

(6) Shell 2
$ cat /proc/net/dev
lo ...

Back to normality.


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
