From: Arthur Helfstein Fragoso <arthur@life.net.br>
Subject: PROBLEM: Regression - Can't upload some data in my network - Destination
 unreachable (Fragmentation needed)
Date: Mon, 24 Nov 2014 02:51:20 -0200
Message-ID: <5472B948.1040802@life.net.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-03c.idc2.mandic.com.br ([177.70.124.30]:43254 "EHLO
	smtp-03.idc2.mandic.com.br" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750828AbaKXFBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 00:01:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

A few years ago, I was using Fedora 16 and I was unable to do any HTTP
POST at the place where I work. I also could not upload files via FTP,
send emails or do a 'git push'. So I tried Ubuntu 12.04 (or 12.10, I'm
not quite sure) and it worked perfectly.
Recently I updated it to 14.04 and the same problem I had in Fedora
came back.
I'm not an expert in understanding network packages, but by googling I
read that it could be that the network manager could have blocked the
ICMP MTU dicovery package. I could try to ask the network manager to
find a way to fix it, but I think more people could also have this
problem somewhere in the world.

I asked in Ubuntu's lauchpad, and Christopher M. Penalver guided me to
do a bisection.

I only have this problem at the place where I work and it happens with
any machine with a kernel older than 3.5. most use windows there and
they don't have this problem.

I did a bisection and I also have a wireshark output.

Those attachments are all in lauchpad.

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1349000

Recently there were some changes in the network, the bug stills
affects some upload services, like: git push, and sending messages in
pidgin...


Let me know what I could do or provide to help to fix this problem.




Bisection results:

3.5.0 is good

c0efc887dcadbdbfe171f028acfab9c7c00e9dde is good.

97bab73f987e2781129cd6f4b6379bf44d808cc6 - gives me a kernel panic
when trying to do an upload of data.

7b34ca2ac7063f4ebf07f85fd75253ed84d5c648 - same problem, kernel panic
when trying to do an upload of data.

The kernel panic goes up to 352e04b9111d608bd89ba7bd8070846d4f97d104

352e04b9111d608bd89ba7bd8070846d4f97d104 - doesn't give me a kernel
panic, but it just hangs when trying to upload data, and this is the
problem that I currently face in the upstream kernel.


to test what versions were good or bad, I tried to do an upload by
doing a 'git push' in a test repository. the bad versions just hanged
when I did 'git push'.



Thank you,

Arthur Helfstein Fragoso
