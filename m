From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/3] mlsxfrm: Various fixes
Date: Wed, 08 Nov 2006 23:08:12 -0500
Message-ID: <4552A9AC.3060708@hp.com>
References: <000501c70342$83b9df70$cc0a010a@tcssec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: 'James Morris' <jmorris@namei.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:26793 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1424036AbWKIEIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 23:08:14 -0500
To: vyekkirala@TrustedCS.com
In-Reply-To: <000501c70342$83b9df70$cc0a010a@tcssec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>>Fix SO_PEERSEC for tcp sockets to return the security context of
>>>the peer (as represented by the SA from the peer) as opposed to the
>>>SA used by the local/source socket.
>>
>>What about the case of a localhost TCP connection not using
>>xfrm labeling?
>>
>>Joe Nall raised this as an important requirement.
> 
> Yes. We need to come up with some new ideas on this (the failed
> secid-recon patchset sought to do this using the secmark field
> on the skb).

You mentioned in an earlier thread that it may be possibile to enable XFRM for
localhost via a sysctl variable; I would think this would make the most sense.
I understand there is a performance hit due to IPsec being used, but I think
this solution offers a few advantages:

1. Functionality is available right now, no additional kernel changes needed
2. No special handling for localhost, I tend to like the idea of having
consistent behavior for all addresses/interfaces

Besides the performance penalty of IPsec and the untested nature of this
solution is there some gotcha here which would prevent this from working?

-- 
paul moore
linux security @ hp
