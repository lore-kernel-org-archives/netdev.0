From: "Chad N. Tindel" <chad@tindel.net>
Subject: Problems reading from /proc/net/tcp
Date: Tue, 12 Oct 2004 01:23:23 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20041012052323.GA62811@calma.pair.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

I'm seeing really bizarre behavior when reading from /proc/net/tcp.  On a 
completely unloaded system (4 CPUs, no application processes running), 
it can take multiple seconds just to cat this file.  The /proc/net/tcp file
only has 21 lines in it, so it isn't like there are just tons of socket
connections.  Here's an example:

[root@hpq11 root]# time cat /proc/net/tcp > /dev/null
 
real    0m3.253s
user    0m0.000s
sys     0m0.000s

However, if the system is really loaded (I'm running make -j 8 bzImage), it
speeds up:

[root@hpq11 root]# time cat /proc/net/tcp > /dev/null
 
real    0m0.487s
user    0m0.000s
sys     0m0.000s

I searched around on google and could only find the following discussion:

http://www.ussg.iu.edu/hypermail/linux/kernel/0110.2/0475.html

However, it is from 2001 so I'm not really sure how relevant it is.

The machine in question has 2 GB of RAM.  dmesg displays the following output:

[root@hpq11 etc]# dmesg | grep Hash
TCP: Hash tables configured (established 524288 bind 65536)

The above mentioned thread seems to say that the TCP Connection Hash Table
Size is too big, and that is why /proc/net/tcp takes so long.  However, it
offers no information on how to correct the problem, and I can't seem to find
any documentation that tells me what tunable I need to modify to make this
problem go away (is there a way to reduce the hash table size?).

An identical machine with the same memory size and same kernel (and same dmesg
output) does not have this problem.  Both machines are running 
Redhat 3 Update 3.

If this problem has already been discussed ad nauseum, any help or quick
pointer would be very much appreciated. 

Regards,

Chad
