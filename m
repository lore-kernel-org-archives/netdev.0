From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [bisected] e341694e3eb5 netlink_lookup() rcu conversion causes
 latencies
Date: Sat, 11 Oct 2014 10:36:27 +0200
Message-ID: <20141011083627.GB5074@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ursula Braun <braunu@de.ibm.com>
To: Thomas Graf <tgraf@suug.ch>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

it just came to my attention that commit e341694e3eb5
"netlink: Convert netlink_lookup() to use RCU protected hash table"
causes network latencies for me on s390.

The testcase is quite simple and 100% reproducible on s390:

Simply login via ssh to a remote system which has the above mentioned
patch applied. Any action like pressing return now has significant
latencies. Or in other words, working via such a connection becomes
a pain ;)

I haven't debugged it, however I assume the problem is that a) the
commit introduces a synchronize_net() call und b) s390 kernels
usually get compiled with CONFIG_HZ_100 while most other architectures
use CONFIG_HZ_1000.
If I change the kernel config to CONFIG_HZ_1000 the problem goes away,
however I don't consider this a fix...

Another reason why this hasn't been observed on x86 may or may not be
that we haven't implemented CONFIG_HAVE_CONTEXT_TRACKING on s390 (yet).
But that's just guessing...
