From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6420] New: iptables is complaining with bogus
 unknown error 18446744073709551615
Date: Thu, 20 Apr 2006 23:26:59 -0700
Message-ID: <20060420232659.357018de.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mvolaski@aecom.yu.edu,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40102 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751065AbWDUG2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 02:28:01 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 20 Apr 2006 23:17:58 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6420] New: iptables is complaining with bogus unknown error 18446744073709551615


http://bugzilla.kernel.org/show_bug.cgi?id=6420

           Summary: iptables is complaining with bogus unknown error
                    18446744073709551615
    Kernel Version: 2.6.17-rc2
            Status: NEW
          Severity: normal
             Owner: laforge@gnumonks.org
         Submitter: mvolaski@aecom.yu.edu


At least since 2.6.1.16.1, many calls to iptables no longer function at least
under 64-bit x86, presumably due to a bug in the netfilter kernel code.

The problem is still present in 2.6.17-rc2.

The error from iptables is
iptables: unknown error 18446744073709551615

Examples of rules that give the error are

1) iptables -A INPUT -i bond0 -s 129.98.90.0/24 -p tcp --dport 548 -j ACCEPT
2) iptables -A INPUT -i bond0 -s 129.98.90.101/32 -p tcp --dport 497 -j ACCEPT
3) iptables -A INPUT -i bond0 -s 129.98.90.227/32 -p tcp --dport 22 -j ACCEPT

Example of a rule that does not give the error:
1) iptables -A INPUT -i bond0 -p ICMP --icmp-type echo-request -s
129.98.90.13/32 -j ACCEPT

The computer is using IPv4 and not IPv6, which has not been compiled into the
kernel.

iptables is version 1.3.5.

Kernel configuration related to iptables follows:

CONFIG_IP_NF_CONNTRACK=m
CONFIG_IP_NF_CT_ACCT=y
CONFIG_IP_NF_CONNTRACK_MARK=y
CONFIG_IP_NF_CONNTRACK_EVENTS=y
CONFIG_IP_NF_CONNTRACK_NETLINK=m
# CONFIG_IP_NF_CT_PROTO_SCTP is not set
CONFIG_IP_NF_FTP=m
# CONFIG_IP_NF_IRC is not set
# CONFIG_IP_NF_NETBIOS_NS is not set
# CONFIG_IP_NF_TFTP is not set
# CONFIG_IP_NF_AMANDA is not set
# CONFIG_IP_NF_PPTP is not set
# CONFIG_IP_NF_H323 is not set
# CONFIG_IP_NF_QUEUE is not set
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_IPRANGE=m
CONFIG_IP_NF_MATCH_TOS=m
CONFIG_IP_NF_MATCH_RECENT=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_DSCP=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_MATCH_OWNER=m
CONFIG_IP_NF_MATCH_ADDRTYPE=m
CONFIG_IP_NF_MATCH_HASHLIMIT=m
CONFIG_IP_NF_FILTER=m
# CONFIG_IP_NF_TARGET_REJECT is not set
CONFIG_IP_NF_TARGET_LOG=m
CONFIG_IP_NF_TARGET_ULOG=m
CONFIG_IP_NF_TARGET_TCPMSS=m
# CONFIG_IP_NF_NAT is not set
CONFIG_IP_NF_MANGLE=m
# CONFIG_IP_NF_TARGET_TOS is not set
# CONFIG_IP_NF_TARGET_ECN is not set
# CONFIG_IP_NF_TARGET_DSCP is not set
# CONFIG_IP_NF_TARGET_TTL is not set
# CONFIG_IP_NF_TARGET_CLUSTERIP is not set
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
# CONFIG_NETFILTER_XT_TARGET_CONNMARK is not set
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
# CONFIG_NETFILTER_XT_TARGET_NOTRACK is not set
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m


lsmod shows
xt_state                4928  0 
ipt_LOG                 8960  0 
ip_conntrack_ftp       10000  0 
ip_conntrack           57880  2 xt_state,ip_conntrack_ftp
nfnetlink               8520  1 ip_conntrack
iptable_filter          5440  0 
ip_tables              22168  1 iptable_filter
x_tables               17800  3 xt_state,ipt_LOG,ip_tables


This issue has been posted to netfilter bugzilla as
https://bugzilla.netfilter.org/bugzilla/show_bug.cgi?id=467

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
