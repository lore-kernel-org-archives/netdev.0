From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 09:39:55 -0400
Message-ID: <1270042795.26743.31.camel@bigi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
	 <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
	 <20100331110345.GC12845@gondor.apana.org.au>
	 <1270040773.26743.12.camel@bigi>
	 <20100331131131.GA13793@gondor.apana.org.au>
	 <20100331132622.GA13908@gondor.apana.org.au>
	 <1270042356.26743.30.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:33904 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933359Ab0CaNj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:39:58 -0400
Received: by qyk9 with SMTP id 9so101838qyk.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 06:39:57 -0700 (PDT)
In-Reply-To: <1270042356.26743.30.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 2010-03-31 at 09:32 -0400, jamal wrote:

> I did not touch pfkey. That behavior remains there. 

Sorry - I lied. I did touch pfkey. Here was my reasoning.

RFC 2367 says flushing behavior should be:
1) user space -> kernel: flush
2) kernel: flush
3) kernel -> user space: flush event to ALL listeners

This is not realistic today in the presence of selinux policies
which may reject the flush etc. So we make the sequence become:
1) user space -> kernel: flush
2) kernel: flush
3) kernel -> user space: flush response to originater from #1
4) if there were no errors then:
kernel -> user space: flush event to ALL listeners

This was in the logs.

cheers,
jamal

