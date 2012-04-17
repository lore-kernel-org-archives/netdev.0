From: Markku Savela <Markku.Savela@vtt.fi>
Subject: rp_filter disabled (all = 0) and still get "martians"
Date: Tue, 17 Apr 2012 15:28:38 +0300
Message-ID: <4F8D61F6.9090405@vtt.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sink.edelkey.net ([213.138.147.137]:59862 "EHLO
	sink.edelkey.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756072Ab2DQMri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 08:47:38 -0400
Received: from vttcashub1.ad.vtt.fi (213214159140.edelkey.net [213.214.159.140])
	by sink.edelkey.net (8.14.2/8.14.2) with ESMTP id q3HCSd6w006871
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 15:28:39 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been trying to some IPsec with Click, and I thought
tunneling would be trivial: just enable forwarding
and disable rp_filters -- no such luck! I've

eth1: 192.168.0.14/24
tun0: 10.0.0.1/8

What tun0 basicly tries to do, is to add

dst 10.0.0.2 -> tun0 -> ...
   ... User space adds tunnel
   ...   dst=192.168.0.15
   ...   src=192.168.0.14
   ... and returns packet to tun0
-> tun0 -> expect it to be routed to eth1

But, I still get it dropped as martian, maybe
due to src address? (Routes fine if src is not
192.168.0.14, like 192.168.1.14).

[ 2801.224711] martian source 192.168.0.15 from 192.168.0.14, on dev tun0

Is there any way to disable this "feature"?

And, even better, it would be wonderful, if
specifying src=0.0.0.0 would automatically
fill in the correct source depending on the
final interface.

I'm doing this on

2.6.38-14-generic #58-Ubuntu SMP Tue Mar 27 18:48:46 UTC 2012 i686 i686 
i386 GNU/Linux
