From: Wenji Wu <wenji@fnal.gov>
Subject: [patch 2/4] - Potential performance bottleneck for Linxu TCP
Date: Wed, 29 Nov 2006 17:29:27 -0600
Message-ID: <HNEBLGGMEGLPMPPDOPMGKEAKCGAA.wenji@fnal.gov>
References: <HNEBLGGMEGLPMPPDOPMGGEAKCGAA.wenji@fnal.gov>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_wvR+8WWOia3zqV21TjrsPg)"
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934462AbWK2X3e@vger.kernel.org>
In-reply-to: <HNEBLGGMEGLPMPPDOPMGGEAKCGAA.wenji@fnal.gov>
To: netdev@vger.kernel.org, davem@davemloft.net, akpm@osdl.org,
	linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_wvR+8WWOia3zqV21TjrsPg)
Content-type: text/plain; charset=iso-8859-1
Content-transfer-encoding: 7BIT


From: Wenji Wu <wenji@fnal.gov>

Greetings,

For Linux TCP, when the network applcaiton make system call to move data
from
socket's receive buffer to user space by calling tcp_recvmsg(). The socket
will
be locked. During the period, all the incoming packet for the TCP socket
will go
to the backlog queue without being TCP processed. Since Linux 2.6 can be
inerrupted mid-task, if the network application expires, and moved to the
expired array with the socket locked, all the packets within the backlog
queue
will not be TCP processed till the network applicaton resume its execution.
If
the system is heavily loaded, TCP can easily RTO in the Sender Side.

Attached is the patch 2/4

best regards,

wenji

Wenji Wu
Network Researcher
Fermilab, MS-368
P.O. Box 500
Batavia, IL, 60510
(Email): wenji@fnal.gov
(O): 001-630-840-4541

--Boundary_(ID_wvR+8WWOia3zqV21TjrsPg)
Content-type: application/octet-stream; name=sched.h.patch
Content-transfer-encoding: QUOTED-PRINTABLE
Content-disposition: attachment; filename=sched.h.patch

--- linux-2.6.14-old/include/linux/sched.h=092006-11-29 16:25:42.0000=
00000 -0600=0A+++ linux-2.6.14/include/linux/sched.h=092006-11-29 10:=
32:55.000000000 -0600=0A@@ -813,6 +813,9 @@=0A =09int cpuset_mems_gen=
eration;=0A #endif=0A =09atomic_t fs_excl;=09/* holding fs exclusive =
resources */=0A+=09int backlog_flag; =09/* packets wait in tcp backlo=
g queue flag */=0A+=09int extrarun_flag;=09/* extra run flag for TCP =
performance */=0A+=0A };=0A =0A static inline pid_t process_group(str=
uct task_struct *tsk)=0A=

--Boundary_(ID_wvR+8WWOia3zqV21TjrsPg)--
