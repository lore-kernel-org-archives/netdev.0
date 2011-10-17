From: "Vaittinen, Matti (EXT-Other - FI/Oulu)"
	<matti.vaittinen.ext@nsn.com>
Subject: IPv6 routing requests ignore NLM_F_CREATE and NLM_F_REPLACE
Date: Mon, 17 Oct 2011 12:06:00 +0300
Message-ID: <82C9FC7ED59434458AD4E09AFF2DE230B53202@FIESEXC006.nsn-intra.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:13545 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab1JQJfu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 05:35:50 -0400
Received: from demuprx016.emea.nsn-intra.net ([10.150.129.55])
	by demumfd001.nsn-inter.net (8.12.11.20060308/8.12.11) with ESMTP id p9H966gx020668
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 11:06:07 +0200
Received: from demuexc024.nsn-intra.net (demuexc024.nsn-intra.net [10.159.32.11])
	by demuprx016.emea.nsn-intra.net (8.12.11.20060308/8.12.11) with ESMTP id p9H95ucu017214
	for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 11:06:06 +0200
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi dee Ho!

I was enchancing an userspace application configuring IPv4 routes via
netlink sockets to support IPv6 route configuration too. While doing
this I noticed that NLM_F_* flags seemed to have no handling at IPv6
side. For example replacing a route to some destiantion, with route
having different pref_src (or metric or gateway or...) can be done by
having NLM_F_REPLACE flag specified in netlink request and leaving out
NLM_F_CREATE.

However with IPv6, if new route being requested has different properties
(like gateway or metric or..) the existing one will not be replaced.
Instead a new route will be created - even if NLM_F_CREATE was not
specified in request.

That causes some inconvenience when a route is being changed. Routes
need to be queried, and matching route needs to be explisitly deleted by
userspace application. Also creating new route even without NLM_F_CREATE
feels a bit strange to me.

I was wondering if this is a bug or wanted behaviour? I was thinking of
trying to write a patch to add support for replacing a route, but I feel
I'm a bit lost with the fib :) I guess the fib6_add_rt2node function
could be changed to inspect the NLM_F_ flags from nl_info pointer, and
to perform replace instead of returning -EEXIST / performing insertion.
Also returning error when NLM_F_CREATE is not specified, and existing
route is not found could propably be implemented.

Anyways, before I spend more time trying to understand the data
structures in fib6, I would like to ask if the handling of NLM_F_* flags
is dropped out in purpose?


Br. Matti Vaittinen

--

Theory:
Theoretical approach means that everything is well known, but still
nothing works.
Practice:
Practical approach means that everything works but no one knows why.

Thank God we have theory and practice balanced here. Nothing works, and
no one knows why...
