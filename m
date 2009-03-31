From: Jeremy Jackson <jerj@coplanar.net>
Subject: keeping ifindex in 16bits or does it have to be sparse?
Date: Tue, 31 Mar 2009 11:08:17 -0400
Message-ID: <1238512097.22664.190.camel@ragnarok>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:52250 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756545AbZCaPUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 11:20:36 -0400
Received: from [70.47.139.174] (ragnarok.coplanar.net [70.47.139.174] (may be forged))
	(authenticated bits=0)
	by titan.coplanar.net (8.14.2/8.14.2/Debian-2build1) with ESMTP id n2VF8NuM027587
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 11:08:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The question came up when profiling Quagga... a performance issue occurs
because it's iterating over a linked list of interface structures... and
this person is using 2000 interfaces for ADSL PPPoE server.  It's an
interesting use case.

There are 2 options to make the interface lookup in quagga scale: array
or hash.  My first thought was array, but it seems that ifindex can get
sparse, that is, the largest ifindex can be much bigger (eg 408589) the
number of max number of interfaces.

So question to netdev, is it possible to reuse ifindex eventually, so it
won't keep growing with interface add/delete, and are there
(unnecessary) large jumps in the allocation sequence?

-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

