From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls
 on v3.
Date: Fri, 12 Dec 2014 22:30:22 +0100
Message-ID: <548B5E6E.6010208@intra2net.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <2630078.LdJXSsPB40@h2o.as.studentenwerk.mhn.de> <1418405225.13491.19.camel@edumazet-glaptop2.roam.corp.google.com> <4013455.miJUA6iczs@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Wolfgang Walter <linux@stwm.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:56231 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbaLLVa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 16:30:26 -0500
In-Reply-To: <4013455.miJUA6iczs@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang,

On 12/12/2014 09:31 PM, Wolfgang Walter wrote:
> There is one thing which indicates that there is also a problen in the GSO 
> path, though. As my tests demonstrated disabling GSO on the physical interface 
> serving the ipsec tunnel does not prevent the hangs. It does, though, if sk-
>> sk_gso_max_segs = 1 in sk_setup_caps() if sk_can_gso(sk) returns false. This 
> was the first variation of the patch where sk->sk_gso_max_segs was not set if 
> dst->header_len() is non zero.

if it's any help: Disabling TX checksumming prevents the hang
even on an unpatched 3.14.x kernel. You could check with your debug statements
in place the path of the packets with and without TX checksumming.

HTH,
Thomas
