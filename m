From: <abirvalg@lavabit.com>
Subject: /proc/net/tcp6 inconsistent line length
Date: Tue, 17 Jan 2012 15:29:19 +0000
Message-ID: <20120117152919.7746a3f9@wwwwww-701SD>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from karen.lavabit.com ([72.249.41.33]:48192 "EHLO karen.lavabit.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753578Ab2AQN3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 08:29:12 -0500
Received: from b.earth.lavabit.com (b.earth.lavabit.com [192.168.111.11])
	by karen.lavabit.com (Postfix) with ESMTP id 85B5E11BC45
	for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 07:29:09 -0600 (CST)
Received: from wwwwww-701sd (46.109.128.192)
	by lavabit.com with ESMTP id C9FSOZ3A19UX
	for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 07:29:09 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My application relies heavily on the constant number of chars in a line of /proc/net/tcp* files

/proc/net/tcp does pad have such constancy
0: 000000:006F .......
1: 000000:DD36 .......
2: 000000:B23A .......
We know that 1 is exactly 150 chars after 0 and 2 is exactly 150 chars after 1 and so forth.

There is no such consistency with /proc/net/tcp6, i.e.

  sl  local_address                         remote_address                        st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
   0: 00000000000000000000000000000000:DD36 00000000000000000000000000000000:0000 0A 00000000:00000000 00:00000000 00000000  1000        0 162811 1 ea464b00 300 0 0 2 -1
   1: 0000000000000000FFFF00000100007F:225B 00000000000000000000000000000000:0000 0A 00000000:00000000 00:00000000 00000000  1000        0 109176 1 ea464000 300 0 0 2 -1
   2: 0000000000000000FFFF00007201A8C0:A4F4 0000000000000000FFFF000009A6D38C:0050 08 00000000:00000001 00:00000000 00000000  1000        0 3128779 1 c210f700 66 4 0 3 2
   3: 0000000000000000FFFF00007201A8C0:AD90 0000000000000000FFFF00001AC64F42:0050 08 00000000:00000001 00:00000000 00000000  1000        0 3128796 1 ea465600 4800 4 0 3 2
   4: 0000000000000000FFFF00007201A8C0:DD24 0000000000000000FFFF00002CD8D2CF:0050 01 00000000:00000000 00:00000000 00000000  1000        0 3128263 1 c210ec00 295 0 0 3 2
   5: 0000000000000000FFFF00007201A8C0:BBC6 0000000000000000FFFF000063E8B244:0050 01 00000000:00000000 00:00000000 00000000  1000        0 3128375 1 c210c580 4800 0 0 4 2

(word wrap need to turned off when viewing this to better understand my point.
Here the amount of chars fluctuate:
between 0 and 1 = 170 chars
between 1 and 2 = 170 chars
between 2 and 3 = 169 chars
between 3 and 4 = 171 chars
between 4 and 5 = 170 chars

Is it possible to implement a constant amount of chars in one line just like in /proc/net/tcp.
This is very helpful for parsing when you extract i.e. the source port, then seek 150 chars and extract the next line's source port and so on.

My application parses /proc/net/tcp6 at least 4 times per second, so the overhead of figuring out the length of each line and subtracting the offset is quite expensive.

P.S. Please CC me when replying to this thread
