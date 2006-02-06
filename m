From: Horms <horms@verge.net.au>
Subject: Re: [PATCH][RFC] Shrink ip_vs_*.c includes
Date: Mon, 6 Feb 2006 18:13:21 +0900
Message-ID: <20060206091319.GH27206@verge.net.au>
References: <43E69CE1.2030204@drugphish.ch>
Reply-To: "LinuxVirtualServer.org users mailing list." <lvs-users@LinuxVirtualServer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "LinuxVirtualServer.org users mailing list." <lvs-users@LinuxVirtualServer.org>
Return-path: <lvs-users-bounces@LinuxVirtualServer.org>
To: Roberto Nibali <ratz@drugphish.ch>
Content-Disposition: inline
In-Reply-To: <43E69CE1.2030204@drugphish.ch>
Cc: netdev@vger.kernel.org
List-Unsubscribe: <http://www.in-addr.de/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@LinuxVirtualServer.org?subject=unsubscribe>
List-Archive: <http://www.in-addr.de/pipermail/lvs-users>
List-Post: <mailto:lvs-users@LinuxVirtualServer.org>
List-Help: <mailto:lvs-users-request@LinuxVirtualServer.org?subject=help>
List-Subscribe: <http://www.in-addr.de/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@LinuxVirtualServer.org?subject=subscribe>
Sender: lvs-users-bounces@LinuxVirtualServer.org
Errors-To: lvs-users-bounces@LinuxVirtualServer.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 06, 2006 at 01:48:33AM +0100, Roberto Nibali wrote:
> Hello,
> 
> This patch against the latest GIT HEAD reduces the includes to the 
> necessary ones. I've compile-tested it against following (and s/y/m/) 
> configuration on x86:
> 
> CONFIG_IP_VS=y
> CONFIG_IP_VS_DEBUG=y
> CONFIG_IP_VS_TAB_BITS=12
> CONFIG_IP_VS_PROTO_TCP=y
> CONFIG_IP_VS_PROTO_UDP=y
> CONFIG_IP_VS_PROTO_ESP=y
> CONFIG_IP_VS_PROTO_AH=y
> CONFIG_IP_VS_RR=y
> CONFIG_IP_VS_WRR=y
> CONFIG_IP_VS_LC=y
> CONFIG_IP_VS_WLC=y
> CONFIG_IP_VS_LBLC=y
> CONFIG_IP_VS_LBLCR=y
> CONFIG_IP_VS_DH=y
> CONFIG_IP_VS_SH=y
> CONFIG_IP_VS_SED=y
> CONFIG_IP_VS_NQ=y
> CONFIG_IP_VS_FTP=y
> 
> Please consider applying (but test it first on your local tree since we 
> don't want stupid breakage resulting from such changes).
> 
> Alternatively/additionally I could envision a patch on top of this one 
> that completely removes the includes from the ../net/ipv4/ipvs/*.c 
> except the ../include/net/ip_vs.h, which would carry all the needed 
> header includes.

Hi Rats, 

I'm all for this patch, but I get horrible breakage with the following
config (I can give the rest if you need it).

CONFIG_IP_VS=m
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m
CONFIG_IP_VS_FTP=m

# make
  CHK     include/linux/version.h
  CHK     include/linux/compile.h
  CHK     usr/initramfs_list
  CC [M]  net/ipv4/ipvs/ip_vs_conn.o
net/ipv4/ipvs/ip_vs_conn.c: In function 'ip_vs_conn_array':
net/ipv4/ipvs/ip_vs_conn.c:672: error: dereferencing pointer to incomplete type
net/ipv4/ipvs/ip_vs_conn.c: In function 'ip_vs_conn_seq_start':
net/ipv4/ipvs/ip_vs_conn.c:684: error: dereferencing pointer to incomplete type
net/ipv4/ipvs/ip_vs_conn.c:685: error: 'SEQ_START_TOKEN' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_conn.c:685: error: (Each undeclared identifier is reported only once
net/ipv4/ipvs/ip_vs_conn.c:685: error: for each function it appears in.)
net/ipv4/ipvs/ip_vs_conn.c: In function 'ip_vs_conn_seq_next':
net/ipv4/ipvs/ip_vs_conn.c:691: error: dereferencing pointer to incomplete type
net/ipv4/ipvs/ip_vs_conn.c:695: error: 'SEQ_START_TOKEN' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_conn.c:708: error: dereferencing pointer to incomplete type
net/ipv4/ipvs/ip_vs_conn.c:713: error: dereferencing pointer to incomplete type
net/ipv4/ipvs/ip_vs_conn.c: In function 'ip_vs_conn_seq_stop':
net/ipv4/ipvs/ip_vs_conn.c:719: error: dereferencing pointer to incomplete type
net/ipv4/ipvs/ip_vs_conn.c: In function 'ip_vs_conn_seq_show':
net/ipv4/ipvs/ip_vs_conn.c:728: error: 'SEQ_START_TOKEN' undeclared (first use in this function)
net/ipv4/ipvs/ip_vs_conn.c:729: warning: implicit declaration of function 'seq_puts'
net/ipv4/ipvs/ip_vs_conn.c:734: warning: implicit declaration of function 'seq_printf'
net/ipv4/ipvs/ip_vs_conn.c: At top level:
net/ipv4/ipvs/ip_vs_conn.c:746: error: variable 'ip_vs_conn_seq_ops' has initializer but incomplete type
net/ipv4/ipvs/ip_vs_conn.c:747: error: unknown field 'start' specified in initializer
net/ipv4/ipvs/ip_vs_conn.c:747: warning: excess elements in struct initializer
net/ipv4/ipvs/ip_vs_conn.c:747: warning: (near initialization for 'ip_vs_conn_seq_ops')
net/ipv4/ipvs/ip_vs_conn.c:748: error: unknown field 'next' specified in initializer
net/ipv4/ipvs/ip_vs_conn.c:748: warning: excess elements in struct initializer
net/ipv4/ipvs/ip_vs_conn.c:748: warning: (near initialization for 'ip_vs_conn_seq_ops')
net/ipv4/ipvs/ip_vs_conn.c:749: error: unknown field 'stop' specified in initializer
net/ipv4/ipvs/ip_vs_conn.c:749: warning: excess elements in struct initializer
net/ipv4/ipvs/ip_vs_conn.c:749: warning: (near initialization for 'ip_vs_conn_seq_ops')
net/ipv4/ipvs/ip_vs_conn.c:750: error: unknown field 'show' specified in initializer
net/ipv4/ipvs/ip_vs_conn.c:750: warning: excess elements in struct initializer
net/ipv4/ipvs/ip_vs_conn.c:750: warning: (near initialization for 'ip_vs_conn_seq_ops')
net/ipv4/ipvs/ip_vs_conn.c: In function 'ip_vs_conn_open':
net/ipv4/ipvs/ip_vs_conn.c:755: warning: implicit declaration of function 'seq_open'
net/ipv4/ipvs/ip_vs_conn.c: At top level:
net/ipv4/ipvs/ip_vs_conn.c:759: error: 'THIS_MODULE' undeclared here (not in a function)
net/ipv4/ipvs/ip_vs_conn.c:761: error: 'seq_read' undeclared here (not in a function)
net/ipv4/ipvs/ip_vs_conn.c:762: error: 'seq_lseek' undeclared here (not in a function)
net/ipv4/ipvs/ip_vs_conn.c:763: error: 'seq_release' undeclared here (not in a function)
make[3]: *** [net/ipv4/ipvs/ip_vs_conn.o] Error 1
make[2]: *** [net/ipv4/ipvs] Error 2
make[1]: *** [net/ipv4] Error 2
make: *** [net] Error 2

-- 
Horms
