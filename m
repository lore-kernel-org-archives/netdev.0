From: Alan Modra <amodra@gmail.com>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Wed, 1 May 2013 13:24:25 +0930
Message-ID: <20130501035425.GD5221@bubble.grove.modra.org>
References: <1367370761.11020.22.camel@edumazet-glaptop>
 <20130501115103.58e40f37@kryten>
 <1367375060.11020.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anton Blanchard <anton@samba.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org,
	Paul Mackerras <paulus@samba.org>,
	Ambrose Feinstein <ambrose@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:37314 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759701Ab3EADyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 23:54:33 -0400
Received: by mail-da0-f47.google.com with SMTP id p1so520895dad.6
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 20:54:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1367375060.11020.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 07:24:20PM -0700, Eric Dumazet wrote:
> 	li 11,1
> 	ld 0,0(9)
> 	rldimi 0,11,31,32
> 	std 0,0(9)
> 	blr
> 	.ident	"GCC: (GNU) 4.6.3"
> 
> You can see "ld 0,0(9)" is used : its a 64 bit load.

Yup.  This is not a powerpc64 specific problem.  See
http://gcc.gnu.org/bugzilla/show_bug.cgi?id=52080
Fixed in 4.8.0 and 4.7.3.

-- 
Alan Modra
Australia Development Lab, IBM
