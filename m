From: "Makan Pourzandi (LMC)" <Makan.Pourzandi@ericsson.ca>
Subject: RE: [PATCH] LSM networking update: summary (0/5)
Date: Fri, 7 Feb 2003 11:58:49 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7B2A7784F4B7F0409947481F3F3FEF8305CC9531@eammlex037.lmc.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: linux-security-module@wirex.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "'James Morris'" <jmorris@intercode.com.au>,
   "David S. Miller"
	 <davem@redhat.com>, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all, 

My comments conecrn the (ip_decode_options, ip_encapsulate and ip_decapsulate) hooks. Even, if James has done much regarding this topic and I'm sure that he knows much more than me about it, I wanted to give my 2 cents on why we should keep these hooks in future releases. 

Actually, we know that based on FIPS documents (http://csrc.nist.gov/publications/fips/fips188/fips188.ps) we can use ip options for security purposes. I believe for my part that this hook can be useful if used to decode ip options and decide to drop or not the ip packets. I don't believe that this level of control can be achieved using other hooks at socket layer. 

In DSI project (security in telecom clustered servers,  www.sourceforge.net/projects/disec), we use this hook for dropping ip packets from processes in the cluster that do not have privileges to communicate to defined nodes in the cluster. Mainly, this hook is useful because it allows us to have a process-level control over communications from a node to another node. I don't believe that this can be achieved with firewalling rules as this means setting up rules for an ip address (which means for all processes in a node in the cluster). Further more, SSL does not cut it as it is based on developer's will and competence to be used properly. 

I believe that the use of ip_decode_options by DSI is only one example and its use can be easily extended to various other cases. 

Regards,
Makan Pourzandi 
-------------------------------------------------------
Makan Pourzandi            
Ericsson Research Canada
http://sourceforge.net/projects/disec/      
-------------------------------------------------------         

This email does not represent or express the opinions of Ericsson
Corporation.

> -----Original Message-----
> From: James Morris [mailto:jmorris@intercode.com.au]
> Sent: Thursday, February 06, 2003 10:11 AM
> To: David S. Miller; kuznet@ms2.inr.ac.ru
> Cc: linux-security-module@wirex.com; netdev@oss.sgi.com
> Subject: [PATCH] LSM networking update: summary (0/5)
> 
> 
> The following five patches are an updated version of the LSM (Linux 
> Security Modules) networking support hooks, submitted for 
> inclusion in 2.5 
> mainline.
> 
> Since the post last week, the networking hooks have been 
> reworked so that
> they are more generalized and do not poke as deeply into network
> protocols.
> 
> Change summary:
> 
>   o The netdevice, skb and ipv4 hooks are gone.
> 
>   o The sock_queue_rcv_skb() hook has been encapsulated within 
>     sk_filter() as suggested by David Miller.
> 
>   o The sk->security field has been removed (use the socket 
> inode field 
>     instead, if needed, or infer the value).
> 
>   o The sk_filter() calls for TCPv4 and TCPv6 have been 
> relocated so that 
>     they are called before skb->dev is cleared (which also fixes a 
>     mainline issue).
> 
>   o An sk_filter() call was added to SCTP.
> 
>   o The default Netlink capability hooks have been inlined so 
> that they do 
>     not call out to a module when CONFIG_SECURITY is disabled, per 
>     requirements from David Miller.
> 
>   o The Netlink hooks now also cover ip6_queue and xfrm_user.
> 
> 
> Full diffstat:
> 
>  include/linux/security.h       |  429 
> ++++++++++++++++++++++++++++++++++++++++-
>  include/net/sock.h             |   95 ++++++---
>  net/core/rtnetlink.c           |    3 
>  net/decnet/dn_nsp_in.c         |   29 +-
>  net/ipv4/netfilter/ip_queue.c  |    3 
>  net/ipv4/tcp_ipv4.c            |    9 
>  net/ipv4/xfrm_user.c           |    3 
>  net/ipv6/netfilter/ip6_queue.c |    6 
>  net/ipv6/tcp_ipv6.c            |   15 -
>  net/netlink/af_netlink.c       |    8 
>  net/sctp/input.c               |    4 
>  net/socket.c                   |   72 ++++++
>  net/unix/af_unix.c             |   16 +
>  security/Kconfig               |    9 
>  security/capability.c          |    2 
>  security/dummy.c               |  135 ++++++++++++
>  16 files changed, 760 insertions(+), 78 deletions(-)
> 
> 
> - James
> -- 
> James Morris
> <jmorris@intercode.com.au>
> 
> 
> _______________________________________________
> linux-security-module mailing list
> linux-security-module@wirex.com
> http://mail.wirex.com/mailman/listinfo/linux-security-module
> 
