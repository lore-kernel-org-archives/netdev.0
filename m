From: James Morris <jmorris@namei.org>
Subject: Re: [RFC][SECMARK 08/08] Add selinux_relabel_packet_permission()
 check to xt_SECMARK
Date: Mon, 8 May 2006 17:19:35 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605081713500.18947@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
 <Pine.LNX.4.64.0605071139330.8588@d.namei> <1147110876.32719.71.camel@jackjack.columbia.tresys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:64922 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750838AbWEHVTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 17:19:38 -0400
To: Karl MacMillan <kmacmillan@tresys.com>
In-Reply-To: <1147110876.32719.71.camel@jackjack.columbia.tresys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 8 May 2006, Karl MacMillan wrote:

> Glad that you added this. This only checks on the addition of rules,
> correct? Obviously changes that don't include an addition (e.g.,
> removal) could change the labeling behavior. Is it possible / needed to
> try to provide anything like the relabelto/relabelfrom pairing that is
> present for files?

The xtables target knows nothing of rule deletion, so we can't detect 
anything there.  All operations require cap_net_admin, though. so we do at 
least have that.

There's also no way to do relabelfrom, as a single rule update actually 
causes the entire 'table' to be replaced, and we have no linkage between 
old and new rules, or in fact, any way to look at the previous state.  It 
turns out that we don't need a relabelfrom anyway, as packets which enter 
the system are inherently unlabeled, and all that SECMARK does is add a 
label, so we know implicitly that setting a label on a packet is always a 
'relabelfrom unlabeled'.


- James
-- 
James Morris
<jmorris@namei.org>
