From: "Jiri Klimes" <klimes@centrum.cz>
Subject: 'ip' command should allow creation of an IPsec SA with 'proto any' and specified sport and dport as selectors
Date: Fri, 24 Apr 2009 13:11:34 +0200
Message-ID: <200904241311.14474@centrum.cz>
References: <200904241303.8959@centrum.cz> <200904241304.13486@centrum.cz> <200904241305.11036@centrum.cz> <200904241306.11421@centrum.cz> <200904241307.10948@centrum.cz> <200904241308.31592@centrum.cz> <200904241309.13171@centrum.cz> <200904241310.10823@centrum.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1012.centrum.cz ([90.183.38.142]:47426 "EHLO
	mail1012.centrum.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbZDXLLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 07:11:39 -0400
Received: by mail1012.centrum.cz id S302051365AbZDXLLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 13:11:34 +0200
In-Reply-To: <200904241310.10823@centrum.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

please find a patch in the attachment.
I propose the patch to allow creation of an IPsec SA shareble by more protocols (TCP, UDP, ...)

Description:

When creating an IPsec SA that sets 'proto any' (IPPROTO_IP) and specifies
'sport' and 'dport' at the same time in selector, the following error is issued:
"sport" and "dport" are invalid with proto=ip

However using IPPROTO_IP with ports is completely legal and necessary when one
wants to share the SA on both TCP and UDP.
One of the applications requiring sharing SAs is 3GPP IMS AKA authentication.

testcase:
ip x s add src 10.0.0.10 dst 10.0.0.20 proto esp spi 0x3113 enc cipher_null ""
auth md5 0xbde359723576fdea08e56cbe876e24ad mode transport sel proto any sport
1234 dport 4321

Note: XFRM allows this programatically.

Could you please review the patch and apply it.

Cheers,
Jiri Klimes

PS: a bug report on this is filed in redhat's bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=497355


