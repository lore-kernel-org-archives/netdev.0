From: Al Boldi <a1426z@gawab.com>
Subject: Re: [PATCH] Netfilter Kconfig:  Expose IPv4/6 connection tracking options by selecting NF_CONNTRACK
Date: Tue, 24 Jul 2007 20:31:58 +0300
Message-ID: <200707242031.58910.a1426z@gawab.com>
References: <200707240836.33494.a1426z@gawab.com> <20070724055208.GB12946@uranus.ravnborg.org> <46A62FB0.2090405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.12.190.228] ([212.12.190.228]:33051 "EHLO raad.intranet"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754387AbXGXRbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 13:31:49 -0400
In-Reply-To: <46A62FB0.2090405@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Sam Ravnborg wrote:
> > On Tue, Jul 24, 2007 at 08:36:33AM +0300, Al Boldi wrote:
> >>Replaces NF_CONNTRACK_ENABLED with NF_CONNTRACK and selects it for
> >>NF_CONNTRACK_IPV4 and NF_CONNTRACK_IPV6
> >>
> >>This exposes IPv4/6 connection tracking options for easier Kconfig
> >> setup.
> >>
> >>Signed-off-by: Al Boldi <a1426z@gawab.com>
> >>Cc: David Miller <davem@davemloft.net>
> >>Cc: Sam Ravnborg <sam@ravnborg.org>
> >>Cc: Andrew Morton <akpm@linux-foundation.org>
> >>---
> >>--- a/net/netfilter/Kconfig	2007-07-09 06:38:52.000000000 +0300
> >>+++ b/net/netfilter/Kconfig	2007-07-24 08:28:06.000000000 +0300
> >>@@ -25,8 +25,7 @@ config NETFILTER_NETLINK_LOG
> >> 	  and is also scheduled to replace the old syslog-based ipt_LOG
> >> 	  and ip6t_LOG modules.
> >>
> >>-# Rename this to NF_CONNTRACK in a 2.6.25
> >>-config NF_CONNTRACK_ENABLED
> >>+config NF_CONNTRACK
>
> We kept this mainly for an easier upgrade. As the comment states, it
> should go in 2.6.25, at which time all people having reconfigured
> their kernel at least once since ip_conntrack was removed will have
> the NF_CONNTRACK option set to the same value as NF_CONNTRACK_ENABLED.
>
> >>--- a/net/ipv4/netfilter/Kconfig	2007-07-09 06:38:50.000000000 +0300
> >>+++ b/net/ipv4/netfilter/Kconfig	2007-07-24 08:27:39.000000000 +0300
> >>@@ -7,7 +7,7 @@ menu "IP: Netfilter Configuration"
> >>
> >> config NF_CONNTRACK_IPV4
> >> 	tristate "IPv4 connection tracking support (required for NAT)"
> >>-	depends on NF_CONNTRACK
> >>+	select NF_CONNTRACK
> >> 	---help---
> >> 	  Connection tracking keeps a record of what packets have passed
> >> 	  through your machine, in order to figure out how they are related
> >>--- a/net/ipv6/netfilter/Kconfig	2007-07-09 06:38:51.000000000 +0300
> >>+++ b/net/ipv6/netfilter/Kconfig	2007-07-24 08:27:54.000000000 +0300
> >>@@ -7,7 +7,8 @@ menu "IPv6: Netfilter Configuration (EXP
> >>
> >> config NF_CONNTRACK_IPV6
> >> 	tristate "IPv6 connection tracking support (EXPERIMENTAL)"
> >>-	depends on INET && IPV6 && EXPERIMENTAL && NF_CONNTRACK
> >>+	depends on INET && IPV6 && EXPERIMENTAL
> >>+	select NF_CONNTRACK
> >> 	---help---
> >> 	  Connection tracking keeps a record of what packets have passed
> >> 	  through your machine, in order to figure out how they are related
> >
> > This change looks wrong.
> > Due to the reverse nature of "select" kconfig cannot fulfill the
> > dependencies of selected symbols. So as a rule of thumb select should
> > only select symbols with no menu and no dependencies to avoid some of
> > the
> > problems that have popped up during the last months.
>
> In this case it looks OK since the dependencies of IPv4 connection
> tracking are (besides NF_CONNTRACK) are superset of those of
> nf_conntrack.
>
> But I vaguely recall having tried this myself and it broke somewhere,
> maybe it was because of the NF_CONNTRACK_ENABLED option, I can't
> recall anymore. Al, if this also works without removal of
> NF_CONNTRACK_ENABLED, please resend without that part.

It doesn't.  But how about this, if you really can't live without 
NF_CONNTRACK_ENBLED:

==================
--- Kconfig.old	2007-07-09 06:38:52.000000000 +0300
+++ Kconfig	2007-07-24 20:24:27.000000000 +0300
@@ -25,8 +25,7 @@ config NETFILTER_NETLINK_LOG
 	  and is also scheduled to replace the old syslog-based ipt_LOG
 	  and ip6t_LOG modules.
 
-# Rename this to NF_CONNTRACK in a 2.6.25
-config NF_CONNTRACK_ENABLED
+config NF_CONNTRACK
 	tristate "Netfilter connection tracking support"
 	help
 	  Connection tracking keeps a record of what packets have passed
@@ -40,9 +39,9 @@ config NF_CONNTRACK_ENABLED
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config NF_CONNTRACK
+config NF_CONNTRACK_ENABLED
 	tristate
-	default NF_CONNTRACK_ENABLED
+	default NF_CONNTRACK
 
 config NF_CT_ACCT
 	bool "Connection tracking flow accounting"
==================


Thanks!

--
Al

