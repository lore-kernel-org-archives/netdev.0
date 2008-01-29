From: jamal <hadi@cyberus.ca>
Subject: RE: Lots of "BUG eth1 code -5 qlen 0" messages in 2.6.24
Date: Tue, 29 Jan 2008 15:57:23 -0500
Message-ID: <1201640243.4431.29.camel@localhost>
References: <20080129184726.GA29300@gateway.home>
	 <D5C1322C3E673F459512FB59E0DDC329046C6CC7@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Erik Mouw <mouw@nl.linux.org>, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:55975 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbYA2U52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 15:57:28 -0500
Received: by py-out-1112.google.com with SMTP id u52so3206825pyb.10
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 12:57:27 -0800 (PST)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329046C6CC7@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-29-01 at 11:57 -0800, Waskiewicz Jr, Peter P wrote:
> > I've just started to use 2.6.24 on my home firewall (before 
> > it was running 2.6.24-rc2 for about 65 days) and I noticed a 
> > couple of error messages I've never seen before:
> > 
> > Jan 29 07:50:54 gateway kernel: BUG eth1 code -5 qlen 0 Jan 
> > 29 08:28:30 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> > 08:57:30 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> > 09:44:04 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> > 10:01:35 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> > 10:01:35 gateway last message repeated 2 times Jan 29 
> > 10:16:48 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> > 10:16:48 gateway last message repeated 2 times Jan 29 
> > 10:45:48 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> > 10:45:48 gateway last message repeated 2 times Jan 29 
> > 11:10:01 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> > 11:10:02 gateway last message repeated 9 times
> > 
> > The message seems to be coming from the qdisc_restart() in 
> > net/sched/sch_generic.c which was changed with commit 
> > 5f1a485d5905aa641f33009019b3699076666a4c .
> > 
> > The NIC is an IBM EtherJet cardbus card using the xircom_cb driver:
> 
> Are you using any specific qdisc, or just the default pfifo_fast?  Have
> you done any specific tuning on your qdisc as well?  The default qlen
> seems to have been changed.

The driver seems buggy. Make it return NETDEV_TX_BUSY instead of -EIO
in xircom_start_xmit() and the messages will go away.

cheers,
jamal



