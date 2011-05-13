From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: question about UFO behavior for bridge device
Date: Fri, 13 May 2011 17:21:07 +0800
Message-ID: <4DCCF803.5020805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: =?UTF-8?B?5Y2V5Y2r?= <shanwei@cn.fujitsu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64962 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758112Ab1EMJVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2011 05:21:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP protocol creates a big packet(skb) in which the data length is greater than MTU.

If device(eth0, lo) does not supports UFO, This big skb will be fragmented to
many fragments in IP protocol, and fragments are sent one by one by device.

But, if device(eth0, lo) supports UFO, IP protocol don't fragment it, and
device directly sends it out.

For bridge device which enable UFO, and Ethernet device(eth0) which not 
support UFO, IP protocol also doesn't fragment it, and bridge forwards original
skb to eth0. For this UFO disabled eth0, kernel needs to perform segmentation
on so big skb in dev_gso_segment(), and link segmented skbs to next field
of original skb. Then device sends segmented skbs out, but not original skb.

But, actually, i saw original big skb in eth0's tcpdump file, but not segmented skbs.
The behavior is right or what we want?
Is there anything missed about my analysis?

-- 
Best Regards
-----
Shan Wei
