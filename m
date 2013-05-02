From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Thu, 2 May 2013 12:02:25 -0500
Message-ID: <1367514145.24411.8@snotra>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	<20130501115103.58e40f37@kryten>
	<1367375060.11020.24.camel@edumazet-glaptop>
	<20130501035425.GD5221@bubble.grove.modra.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; delsp=Yes; format=Flowed
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Ambrose Feinstein <ambrose@google.com>,
	Paul Mackerras <paulus@samba.org>,
	Anton Blanchard <anton@samba.org>,
	<linuxppc-dev@lists.ozlabs.org>, David Miller <davem@davemloft.net>
To: Alan Modra <amodra@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:13114 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760578Ab3EBRCj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 13:02:39 -0400
In-Reply-To: <20130501035425.GD5221@bubble.grove.modra.org> (from
	amodra@gmail.com on Tue Apr 30 22:54:25 2013)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2013 10:54:25 PM, Alan Modra wrote:
> On Tue, Apr 30, 2013 at 07:24:20PM -0700, Eric Dumazet wrote:
> > 	li 11,1
> > 	ld 0,0(9)
> > 	rldimi 0,11,31,32
> > 	std 0,0(9)
> > 	blr
> > 	.ident	"GCC: (GNU) 4.6.3"
> >
> > You can see "ld 0,0(9)" is used : its a 64 bit load.
> 
> Yup.  This is not a powerpc64 specific problem.  See
> http://gcc.gnu.org/bugzilla/show_bug.cgi?id=52080
> Fixed in 4.8.0 and 4.7.3.

FWIW (especially if a GCC version check is added), it seems to have  
been fixed as far back as 4.7.1, not just 4.7.3.

-Scott
