From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Updates to nfsroot documentation (take 2)
Date: Wed, 5 Dec 2007 15:13:04 +0900
Message-ID: <20071205061302.GA2292@verge.net.au>
References: <20071205045932.GA7160@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Amos Waterland <apw@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:43871 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbXLEGNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 01:13:08 -0500
Content-Disposition: inline
In-Reply-To: <20071205045932.GA7160@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ CCed netdev ]

On Tue, Dec 04, 2007 at 11:59:32PM -0500, Amos Waterland wrote:
> The difference between ip=off and ip=::::::off has been a cause of much
> confusion.  Document how each behaves, and do not contradict ourselves
> by saying that "off" is the default when in fact "any" is the default
> and is descibed as being so lower in the file.

This seems fine to me in so far as it is correct.  And I do like the
removal of the duplicat documentation from ipconfig.c.  However, as I
mentioned yesterday, it really seems to me that the code in ipconfig.c
should be updated so that ip=off and ip=::::::off do the same thing.

> 
> Signed-off-by: Amos Waterland <apw@us.ibm.com>
> 
>  Documentation/nfsroot.txt |    9 ++++++---
>  net/ipv4/ipconfig.c       |   20 +-------------------
>  2 files changed, 7 insertions(+), 22 deletions(-)
> 
> diff --git a/Documentation/nfsroot.txt b/Documentation/nfsroot.txt
> index 16a7cae..ac04a1d 100644
> --- a/Documentation/nfsroot.txt
> +++ b/Documentation/nfsroot.txt
> @@ -92,8 +92,11 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>
>    autoconfiguration.
>  
>    The <autoconf> parameter can appear alone as the value to the `ip'
> -  parameter (without all the ':' characters before) in which case auto-
> -  configuration is used.
> +  parameter (without all the ':' characters before).  If the value is
> +  "ip=off" or "ip=none", no autoconfiguration will take place, otherwise
> +  autoconfiguration will take place.  Note that "ip=off" is not the same
> +  thing as "ip=::::::off", because in the latter autoconfiguration will take
> +  place if any of DHCP, BOOTP or RARP are compiled in the kernel.
>  
>    <client-ip>	IP address of the client.
>  
> @@ -142,7 +145,7 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>
>  		into the kernel will be used, regardless of the value of
>  		this option.
>  
> -                  off or none: don't use autoconfiguration (default)
> +                  off or none: don't use autoconfiguration
>  		  on or any:   use any protocol available in the kernel
>  		  dhcp:        use DHCP
>  		  bootp:       use BOOTP
> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
> index c5c107a..96400b0 100644
> --- a/net/ipv4/ipconfig.c
> +++ b/net/ipv4/ipconfig.c
> @@ -1396,25 +1396,7 @@ late_initcall(ip_auto_config);
>  
>  /*
>   *  Decode any IP configuration options in the "ip=" or "nfsaddrs=" kernel
> - *  command line parameter. It consists of option fields separated by colons in
> - *  the following order:
> - *
> - *  <client-ip>:<server-ip>:<gw-ip>:<netmask>:<host name>:<device>:<PROTO>
> - *
> - *  Any of the fields can be empty which means to use a default value:
> - *	<client-ip>	- address given by BOOTP or RARP
> - *	<server-ip>	- address of host returning BOOTP or RARP packet
> - *	<gw-ip>		- none, or the address returned by BOOTP
> - *	<netmask>	- automatically determined from <client-ip>, or the
> - *			  one returned by BOOTP
> - *	<host name>	- <client-ip> in ASCII notation, or the name returned
> - *			  by BOOTP
> - *	<device>	- use all available devices
> - *	<PROTO>:
> - *	   off|none	    - don't do autoconfig at all (DEFAULT)
> - *	   on|any           - use any configured protocol
> - *	   dhcp|bootp|rarp  - use only the specified protocol
> - *	   both             - use both BOOTP and RARP (not DHCP)
> + *  command line parameter.  See Documentation/nfsroot.txt.
>   */
>  static int __init ic_proto_name(char *name)
>  {

-- 
Horms

