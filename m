From: James Morris <jmorris@intercode.com.au>
Subject: LSM networking components for 2.5.42 (intro)
Date: Wed, 16 Oct 2002 00:33:18 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210152333530.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Following this email will be seven patches which provide LSM networking 
components for the 2.5.42 kernel:

1. Netdevice hooks
2. skb hooks
3. Socket hooks
4. IPv4 hooks
5. Netlink hooks
6. Unix domain hooks
7. TCP hooks

These represent all of the current LSM networking features, split 
into cumulative patches.

In a nutshell, LSM (Linux Security Modules) is a general purpose framework 
for access control, allowing various security projects (e.g. SELinux, LIDS 
etc.) to be implemented without needing to patch the kernel.

The basic concept of LSM is 'mediated access to kernel objects', which
roughly translates to placing void pointers into key structs which can be
used to store security state, then adding a series of hooks which
maintain per-object security state and allow access decisions to be made.  
It is up to the security module to implement policies for maintaining
security state and which access hooks to choose (i.e. LSM aims to be
mechanism, not policy).

Much more information on LSM and its design can be found at the LSM web 
site: http://lsm.immunix.org/ , notably the Usenix and OLS papers.

The networking components were largely modeled on the requirements of
SELinux, which is itself a somewhat generic mandatory access control
system.  Specific aims for the networking in LSM are to provide support
for: general access control, the SELinux extended socket API, and labeled
networking.  Several additional projects are believed to be under 
development which make significant use of the networking components, 
although SELinux is the best currently available example.

The performance impact of LSM has been examined using macro (Webstone) and
micro (lmbench) benchmarks on a dual SMP system.  The last set of data,
which was generated around the time of the last kernel summit, indicates
that there is no measurable impact on networking at 100Mbps LAN speeds
(the variations were basically noise).

At 1Gbps, the Webstone throughput figures showed a 1-2% impact, although
it's not clear how much of this is the specific result of the networking
hooks (i.e. non-networking LSM hooks were probably also contributing).  
The bw_tcp microbenchmark showed an impact of 0.3-0.6% at gigabit speed.

Some changes (notably, the recent addition some TCP hooks) have been made
to LSM since these tests, and the tests can be run again if needed.
There's also the issue of the new flow cache code, which will probably
require changes to some of the LSM networking hooks.

The LSM developers are open to suggestions for optimizations and 
improvements, and can be reached reliably at the lsm address on the cc 
list above.


- James
-- 
James Morris
<jmorris@intercode.com.au>
