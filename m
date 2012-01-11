From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] xfrm: Call IP receive handler directly for
	inbound tunnel-mode packets
Date: Wed, 11 Jan 2012 15:45:28 +1100
Message-ID: <20120111044528.GA13790@gondor.apana.org.au>
References: <1325475154-15997-1-git-send-email-david.ward@ll.mit.edu> <20120102072828.GA5380@gondor.apana.org.au> <4F020B04.9000104@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60456 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739Ab2AKEpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 23:45:32 -0500
Content-Disposition: inline
In-Reply-To: <4F020B04.9000104@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 02, 2012 at 02:52:36PM -0500, Ward, David - 0663 - MITLL wrote:
>
> Sorry if I'm missing something, but how are such overruns avoided on the  
> outbound side?

We use tail calls on the output path.

> Assuming there might be a better way to make this change, are there  
> examples of existing setups that would be negatively affected? From my  
> perspective this behavior is just an unintended artifact of xfrm'ed  
> packets being placed back into netif_rx, which only occurs for inbound  
> packets, and it complicates the usage of network taps on these  
> interfaces (i.e. how do you systematically determine whether any packet  
> is post-xfrm and was already seen in an earlier form?). It seems to me  
> that network taps operate at a lower layer than xfrm, and so xfrm should  
> be invisible to the network taps. If users are, for example, capturing  
> ESP packets from a PF_PACKET socket and want to examine the decrypted  
> payload, I think the capture application should be responsible for the  
> decryption, just as it would be at higher layers with something like  
> SSL/TLS (and again for example, both protocols can be decrypted by  
> Wireshark when provided the keys).

While I sympathise with your argument, doing it nearly 10 years
after this behaviour was implemented is just too dangerous IMHO.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
