From: jamal <hadi@cyberus.ca>
Subject: Re: Problem with IPSEC tunnel mode
Date: Thu, 21 Apr 2005 19:50:19 -0400
Message-ID: <1114127419.10572.4.camel@localhost.localdomain>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au>
	 <200504211640.16742.wolfgang.walter@studentenwerk.mhn.de>
	 <20050421214618.GA29991@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050421214618.GA29991@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-22-04 at 07:46 +1000, Herbert Xu wrote:

> 
> > src 10.148.0.0/23 dst 10.0.25.210/32 
> > 	dir fwd priority 0 
> 
> There you go.  This policy trumps your other policy.  This one
> says that forwarded traffic matching it must carry no tunnel
> IPsec transforms.  Therefore all IPsec packets matching it will
> be dropped.
> 
> > src 10.148.4.0/28 dst 10.0.25.210/32 
> > 	dir fwd priority 2084 
> > 	tmpl	src 192.168.9.237 dst 192.168.77.161
> > 		proto esp spi 0x00000000 reqid 16465 mode tunnel
> 
> The reason it worked with the old setkey and 2.6.7* is that all
> forwarded traffic would've been allowed, regardless of whether
> they matched the IPsec policy or not.
> 

Herbert,
What was the reason there exist a FWD direction in the policies?

Also - shouldnt the FWD policies closely match the OUT ones instead of
the IN direction (browsing the forwarding code)? i.e
does this look odd to you (picking a sample from Wolfgangs output):

------------
src 10.148.0.0/23 dst 10.148.3.32/28 
	dir out priority 2372 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 17757 mode tunnel
		

src 10.148.3.32/28 dst 10.148.0.0/23 
	dir fwd priority 2372 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17757 mode tunnel


src 10.148.3.32/28 dst 10.148.0.0/23 
	dir in priority 2372 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17757 mode tunnel

------

Just matched against reqid. 

cheers,
jamal 
