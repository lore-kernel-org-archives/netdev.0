From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Fw: Re: 2.6.9-rc1-mm2
Date: Tue, 31 Aug 2004 17:49:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41351C86.7000704@us.ibm.com>
References: <20040831153450.4498282e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Rick Lindsley <ricklind@us.ibm.com>,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040831153450.4498282e.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

> Getting an error of:
> 
> net/built-in.o(.text+0x64047): In function `tcp_in_window':
> net/ipv4/netfilter/ip_conntrack_proto_tcp.c:683: undefined reference to `ip_ct_log_invalid'
> net/built-in.o(.text+0x6431f): In function `tcp_error':
> net/ipv4/netfilter/ip_conntrack_proto_tcp.c:792: undefined reference to `ip_ct_log_invalid'
> net/built-in.o(.text+0x64421):net/ipv4/netfilter/ip_conntrack_proto_tcp.c:817: undefined reference to `ip_ct_log_invalid'
> net/built-in.o(.text+0x64450):net/ipv4/netfilter/ip_conntrack_proto_tcp.c:808: undefined reference to `ip_ct_log_invalid'
> net/built-in.o(.text+0x64487):net/ipv4/netfilter/ip_conntrack_proto_tcp.c:784: undefined reference to `ip_ct_log_invalid'
> net/built-in.o(.text+0x6478a):net/ipv4/netfilter/ip_conntrack_proto_tcp.c:877: more undefined references to `ip_ct_log_invalid' follow
> 
> The error is for all references of the LOG_INVALID macro in
> ip_conntrack_proto_tcp.c.  My guess is that the declaration of
> ip_ct_log_invalid in ip_conntrack_standalone.c landed under a new #define
> that I'm not using in this set of patches, but I can't find where.
> 
> All-important config file appended below.  This is an older config file, but
> make oldconfig was done first, per normal.

>
> # IP: Netfilter Configuration
> #
> # CONFIG_IP_NF_CONNTRACK is not set
> # CONFIG_IP_NF_QUEUE is not set
> # CONFIG_IP_NF_IPTABLES is not set
> CONFIG_IP_NF_NAT_NEEDED=y
> # CONFIG_IP_NF_ARPTABLES is not set
> CONFIG_IP_NF_COMPAT_IPCHAINS=y

Woiks jes fine with latest default config. Might want to poke those
automated builds to pick up the latest config as well. The connection
tracking source files which include that symbol (ip_conntrack_proto_*.c,
ip_conntrack_standalone.c) should only be included if you have
CONFIG_IP_NF_CONNTRACK defined.

You had NAT_NEEDED set, which does pull in the above files too,
but are now dependent on CONNTRACK being set.

Tested with latest config and several permutations such as conntrack
on/off, etc.

Here is a sample config which built fine, just the netfilter section:


# IP: Netfilter Configuration
#
CONFIG_IP_NF_CONNTRACK=m
CONFIG_IP_NF_FTP=m
CONFIG_IP_NF_IRC=m
CONFIG_IP_NF_TFTP=m
CONFIG_IP_NF_AMANDA=m
CONFIG_IP_NF_QUEUE=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_LIMIT=m
# CONFIG_IP_NF_MATCH_IPRANGE is not set
CONFIG_IP_NF_MATCH_MAC=m
CONFIG_IP_NF_MATCH_PKTTYPE=m
CONFIG_IP_NF_MATCH_MARK=m
CONFIG_IP_NF_MATCH_MULTIPORT=m
CONFIG_IP_NF_MATCH_TOS=m
CONFIG_IP_NF_MATCH_RECENT=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_DSCP=m
CONFIG_IP_NF_MATCH_AH_ESP=m
CONFIG_IP_NF_MATCH_LENGTH=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_MATCH_TCPMSS=m
CONFIG_IP_NF_MATCH_HELPER=m
CONFIG_IP_NF_MATCH_STATE=m
CONFIG_IP_NF_MATCH_CONNTRACK=m
CONFIG_IP_NF_MATCH_OWNER=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_NAT=m
CONFIG_IP_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_REDIRECT=m
# CONFIG_IP_NF_TARGET_NETMAP is not set
# CONFIG_IP_NF_TARGET_SAME is not set
# CONFIG_IP_NF_NAT_LOCAL is not set
CONFIG_IP_NF_NAT_SNMP_BASIC=m
CONFIG_IP_NF_NAT_IRC=m
CONFIG_IP_NF_NAT_FTP=m
CONFIG_IP_NF_NAT_TFTP=m
CONFIG_IP_NF_NAT_AMANDA=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_TOS=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_DSCP=m
CONFIG_IP_NF_TARGET_MARK=m
# CONFIG_IP_NF_TARGET_SAME is not set
# CONFIG_IP_NF_NAT_LOCAL is not set
CONFIG_IP_NF_NAT_SNMP_BASIC=m
CONFIG_IP_NF_NAT_IRC=m
CONFIG_IP_NF_NAT_FTP=m
CONFIG_IP_NF_NAT_TFTP=m
CONFIG_IP_NF_NAT_AMANDA=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_TOS=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_DSCP=m
CONFIG_IP_NF_TARGET_MARK=m
# CONFIG_IP_NF_TARGET_CLASSIFY is not set
CONFIG_IP_NF_TARGET_LOG=m
CONFIG_IP_NF_TARGET_ULOG=m
CONFIG_IP_NF_TARGET_TCPMSS=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m
CONFIG_IP_NF_COMPAT_IPCHAINS=m
CONFIG_IP_NF_COMPAT_IPFWADM=m
# CONFIG_IP_NF_RAW is not set
# CONFIG_IP_NF_MATCH_ADDRTYPE is not set
# CONFIG_IP_NF_MATCH_REALM is not set
# CONFIG_IP_NF_CT_ACCT is not set
# CONFIG_IP_NF_MATCH_SCTP is not set
# CONFIG_IP_NF_CT_PROTO_SCTP is not set
