From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Fri, 22 Feb 2008 15:58:37 +0100
Message-ID: <47BEE31D.7020003@trash.net>
References: <200801291316.m0TDGivY024953@hera.kernel.org>	 <1203428949.3223.25.camel@shinybook.infradead.org>	 <47BAE13D.4060206@trash.net>	 <1203431447.3223.33.camel@shinybook.infradead.org>	 <47BAEB6C.1030609@trash.net> <1203666762.5771.35.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000508060907030904000909"
Cc: netdev@vger.kernel.org, Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com,
	twoerner@redhat.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep20-int.chello.at ([62.179.121.40]:43802 "EHLO
	viefep20-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbYBVO6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 09:58:42 -0500
In-Reply-To: <1203666762.5771.35.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000508060907030904000909
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

David Woodhouse wrote:
> On Tue, 2008-02-19 at 15:45 +0100, Patrick McHardy wrote:
>> That would break iptables compilation, which already includes
>> linux/in.h in some files. I guess the best fix for now is to
>> include netinet/in.h in busybox and long-term clean this up
>> properly.
> 
> It looks like iptables is fairly broken anyway:
> 
> make[1]: Entering directory `/home/dwmw2/working/extras/iptables/devel/iptables-1.4.0'
> Unable to resolve dependency on linux/compiler.h. Try 'make clean'.
> Extensions found:
> make[1]: Leaving directory `/home/dwmw2/working/extras/iptables/devel/iptables-1.4.0'
> error: Bad exit status from /var/tmp/rpm-tmp.32057 (%build)


Yes, that was a bug in the lastest release. We need to
release a 1.4.1 version or something like that, but I'm
not too familiar with the release process, so I haven't
done this so far.

Anyway, I just committed this patch to iptables to remove
the compiler.h inclusions.


--------------000508060907030904000909
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

Index: include/linux/netfilter_ipv6/ip6_tables.h
===================================================================
--- include/linux/netfilter_ipv6/ip6_tables.h	(Revision 7376)
+++ include/linux/netfilter_ipv6/ip6_tables.h	(Arbeitskopie)
@@ -15,7 +15,6 @@
 #ifndef _IP6_TABLES_H
 #define _IP6_TABLES_H
 
-#include <linux/compiler.h>
 #include <linux/netfilter_ipv6.h>
 
 #include <linux/netfilter/x_tables.h>
Index: include/linux/netfilter.h
===================================================================
--- include/linux/netfilter.h	(Revision 7376)
+++ include/linux/netfilter.h	(Arbeitskopie)
@@ -1,8 +1,6 @@
 #ifndef __LINUX_NETFILTER_H
 #define __LINUX_NETFILTER_H
 
-#include <linux/compiler.h>
-
 /* Responses from hook functions. */
 #define NF_DROP 0
 #define NF_ACCEPT 1
Index: include/linux/netfilter_ipv4/ip_tables.h
===================================================================
--- include/linux/netfilter_ipv4/ip_tables.h	(Revision 7376)
+++ include/linux/netfilter_ipv4/ip_tables.h	(Arbeitskopie)
@@ -15,7 +15,6 @@
 #ifndef _IPTABLES_H
 #define _IPTABLES_H
 
-#include <linux/compiler.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <linux/netfilter/x_tables.h>

--------------000508060907030904000909--
