From: Thomas Heinz <creatix@hipac.org>
Subject: tc stack overflow
Date: Sun, 06 Jul 2003 00:21:40 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F074F74.2090308@hipac.org>
Reply-To: Thomas Heinz <creatix@hipac.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

Have you already crashed your kernel today? No? Well, try this one:

# tc qdisc add dev eth0 root handle 1: prio \
   for i in `seq 500` ; do tc qdisc add dev eth0 \
       parent $i:1 handle `expr $i + 1`: prio ; done ; \
   ping 1.2.3.4

[replace eth0 by a device of your choice]


I think some of you are aware of the problem but strangely I didn't
find any mention on linux-kernel or linux-netdev or lartc.

The problem is that the depth of the classification tree is not limited
in any way and since for every qdisc the corresponding enqueue function
is called we have a stack overflow here.

IMO the problem could be fixed by adding a depth parameter to the
enqueue function. This way the function can decide whether it is save
to go deeper down the tree (maybe subject to a global policy).

So, what do you think about the issue? Do you care?


Regards,

Thomas
