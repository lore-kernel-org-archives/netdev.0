From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3323] New: kernel NULL pointer dereference in
 ipv6_get_hoplimit
Date: Tue, 31 Aug 2004 14:04:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831140454.60237c07.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 31 Aug 2004 13:47:12 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3323] New: kernel NULL pointer dereference in ipv6_get_hoplimit


http://bugme.osdl.org/show_bug.cgi?id=3323

           Summary: kernel NULL pointer dereference in ipv6_get_hoplimit
    Kernel Version: 2.6.9-rc1
            Status: NEW
          Severity: normal
             Owner: niv@us.ibm.com
         Submitter: thomasz@hostmaster.org


2.6.9-rc1 oopses here reproducibly during boot after bringing up the
sit3 tunneling device:

Unable to handle kernel NULL pointer dereference...
ipv6_get_hoplimit+24, ipv6_rout_add+1367, inet6_rtm_newroute+63,
rtnetlink_rcv+587, netlink_data_ready+22, netlink_sendskb+46,
netlink_sendmsg+703, sock_sendmsg+174, __mark_inode_dirty+52,
verify_iovec+75, sys_sendmsg+528, cap_vm_enough_memory+14, do_page_fault
+497, netlink_autobind+184, sys_getsockname+135, sock_map_fd+376,
netlink_create+207, system_call+126

Normally with 2.6.8.1 and before my routing table looks like this:

Kernel IPv6 routing table
Destination                                 Next Hop                           
    Flags Metric Ref    Use Iface
::1/128                                     ::                                 
    U     0      104       2 lo
2000::/128                                  2000::                             
    UC    0      12       0 sit1
2001:850:306::/128                          ::                                 
    U     0      9        0 lo
2001:850:306::1/128                         ::                                 
    U     0      6        0 lo
2001:850:306::/64                           ::                                 
    U     256    0        0 sit1
3ffe:80ee:14fa::/128                        ::                                 
    U     0      9        0 lo
3ffe:80ee:14fa::1/128                       ::                                 
    U     0      6        0 lo
3ffe:80ee:14fa::/64                         ::                                 
    U     256    0        0 sit2
3ffe:80ee:14fa::/64                         ::                                 
    U     256    0        0 sit3
2000::/3                                    ::                                 
    U     1      3        0 sit1
2000::/3                                    ::                                 
    U     1      0        0 sit2
2000::/3                                    ::                                 
    U     1      0        0 sit3
fe80::/128                                  ::                                 
    U     0      0        0 lo
fe80::d4ba:6e20/128                         ::                                 
    U     0      0        0 lo
fe80::2e0:81ff:fe29:9983/128                ::                                 
    U     0      0        0 lo
fe80::/64                                   ::                                 
    U     256    0        0 eth0
fe80::/64                                   ::                                 
    U     256    0        0 sit1
fe80::/64                                   ::                                 
    U     256    0        0 sit2
fe80::/64                                   ::                                 
    U     256    0        0 sit3
ff00::/128                                  ff00::                             
    UC    0      12       0 eth0
ff00::/8                                    ::                                 
    U     256    0        0 eth0
ff00::/8                                    ::                                 
    U     256    0        0 sit1
ff00::/8                                    ::                                 
    U     256    0        0 sit2
ff00::/8                                    ::                                 
    U     256    0        0 sit3

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
