From: <denys@visp.net.lb>
Subject: iproute2 caching and batch mode
Date: Sat, 08 Jan 2011 22:09:39 +0200
Message-ID: <0befc7c09f04936c1244eaa5a1d2620c@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: Stephen Hemminger <shemminger@vyatta.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:56867 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab1AHUTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jan 2011 15:19:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

noticed some issue a while ago, and because of recent patches decided to
post my thoughts:

This issue can happen if ip or tc running in some kind of "daemon" batch
mode, or processing large batch file on computer where interfaces can
reappear with same name but different index (pppoe NAS for example).

It is easy to reproduce the problem:

centaur iproute2-2.6.37 # ip/ip -force -batch -
tunnel add test0 mode ipip remote 1.1.1.2 local 1.1.1.1
link show dev test0
201: test0: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN 
    link/ipip 1.1.1.1 peer 1.1.1.2
tunnel del test0
Unsupported family:17

Or:

centaur iproute2-2.6.37 # ip/ip -force -batch -
tunnel del test0
tunnel add test0 mode ipip remote 1.1.1.2 local 1.1.1.1
link show dev test0
202: test0: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN 
    link/ipip 1.1.1.1 peer 1.1.1.2
(another console, delete and create again test0)
link show dev test0
(nothing will appear)

