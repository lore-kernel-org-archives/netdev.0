From: Dilip Daya <dilip.daya@hp.com>
Subject: network-namespace and NETLINK_INET_DIAG - kernel v3.2.39-longterm
Date: Tue, 05 Mar 2013 13:20:49 -0500
Message-ID: <1362507649.2840.55.camel@pro6455b.example.com>
Reply-To: dilip.daya@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:46844 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755899Ab3CESUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 13:20:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric et al,

Re: Network-namespace and NETLINK_INET_DIAG

=> Kernel v3.2.39-longterm

Within a default/host namespace:
--------------------------------

# strace /bin/ss -pim 
execve("/bin/ss", ["/bin/ss", "-pim"], [/* 28 vars */]) = 0
...
...
socket(PF_NETLINK, SOCK_RAW, 4)         = 3  
sendmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000},
            msg_iov(1)=[{"L\0\0\0\22\0\1\3@\342\1\0\0\0\0\0\2\0\0\17\0\0
                          \0\0\0\0\0\0\0\0\0\0"..., 76}],
            msg_controllen=0,
            msg_flags=0}, 0) = 76
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000},
            msg_iov(1)=[{"\344\0\0\0\22\0\2\0@\342\1\0\31|\0\0\2\1\2\0\0
                          \26\353;\300\250\2=088 "..., 8192}],
            msg_controllen=0, msg_flags=0}, 0) = 684
...


# /bin/ss -pim
State       Recv-Q Send-Q   Local Address:Port       Peer Address:Port 
ESTAB       0      0        192.168.2.61:ssh         192.168.2.62:60220
users:(("sshd",7491,3))
mem:(r0,w0,f0,t0) cubic wscale:5,5 rto:216 rtt:18.5/19 ato:40 cwnd:10
 send 6.3Mbps rcv_rtt:4 rcv_space:14480


Within a network-namespace:
---------------------------

# strace /bin/ss -pim 
execve("/bin/ss", ["/bin/ss", "-pim"], [/* 28 vars */]) = 0
...
...
socket(PF_NETLINK, SOCK_RAW, 4)         = 5  
sendmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000},
            msg_iov(1)=[{"L\0\0\0\22\0\1\3@\342\1\0\0\0\0\0\2\0\0\17\0\0
                          \0\0\0\0\0\0\0\0\0\0"..., 76}],
            msg_controllen=0,
            msg_flags=0}, 0) = -1 ECONNREFUSED (Connection refused)
...


# /bin/ss -pim
State       Recv-Q Send-Q   Local Address:Port     Peer Address:Port   
ESTAB       0      0        192.168.2.61:ssh       192.168.2.62:60220
rto:0.21 ato:0.04 cwnd:10 bidir
users:(("sshd",7491,3))


=> Network namespace (kernel v3.2.39-longterm) not allowing /bin/ss
   missing information from structs tcp_info  and  inet_diag_meminfo.
   This is fixed in kernel v3.6-rc1. Are there identifiable patchsets
   from kernel v3.6-rc1 that can be easily backported to
   kernel v3.2.x-longterm ??


Thanks.
-- 
-DilipD.
