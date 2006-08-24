From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/44] [XFRM] IPV6: Restrict bundle reusing
Date: Wed, 23 Aug 2006 19:12:14 -0700 (PDT)
Message-ID: <20060823.191214.10297360.davem@davemloft.net>
References: <11563453663761-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453661892-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61890
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030192AbWHXCML (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:12:11 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453661892-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:17 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> For outbound transformation, bundle is checked whether it is
> suitable for current flow to be reused or not. In such IPv6 case
> as below, transformation may apply incorrect bundle for the flow instead
> of creating another bundle:
> 
> - The policy selector has destination prefix length < 128
>   (Two or more addresses can be matched it)
> - Its bundle holds dst entry of default route whose prefix length < 128
>   (Previous traffic was used such route as next hop)
> - The policy and the bundle were used a transport mode state and
>   this time flow address is not matched the bundled state.
> 
> This issue is found by Mobile IPv6 usage to protect mobility signaling
> by IPsec, but it is not a Mobile IPv6 specific.
> This patch adds strict check to xfrm_bundle_ok() for each
> state mode and address when prefix length is less than 128.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.  Maybe ipv4 side wants to check for prefix length < 32?
Or does it not matter for some reason under ipv4?
