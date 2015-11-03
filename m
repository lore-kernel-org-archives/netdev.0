From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET is
 enabled
Date: Tue, 3 Nov 2015 18:09:52 +0000
Message-ID: <BY2PR0301MB16545CDB0F10CC8DB3058D8EA02B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <1446398459.6254.90.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151101.155859.1206189858863918018.davem@davemloft.net>
	<BY2PR0301MB16547E3AA4FB1F1AC8DE28ECA02B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
 <20151103.103319.1465681990237533576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0131.outbound.protection.outlook.com ([207.46.100.131]:38560
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755662AbbKCSJy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 13:09:54 -0500
In-Reply-To: <20151103.103319.1465681990237533576.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, November 3, 2015 7:33 AM
> To: KY Srinivasan <kys@microsoft.com>
> Cc: eric.dumazet@gmail.com; Haiyang Zhang <haiyangz@microsoft.com>;
> edumazet@google.com; netdev@vger.kernel.org
> Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET
> is enabled
> 
> From: KY Srinivasan <kys@microsoft.com>
> Date: Tue, 3 Nov 2015 07:59:36 +0000
> 
> > I have implemented the scheme we had discussed a few weeks ago. In
> > this new implementation our driver is NOT requesting addition
> > headroom - rndis header and the per packet state is being maintained
> > outside of the skb. What I am seeing is that when I have
> > LL_MAX_HEADER set to 220 bytes, even though our driver is not using
> > the additional head room, I see about a 10% boost in the peak
> > performance (about 34 Gbps on a 40Gbps interface). However, when I
> > set the LL_MAX_HEADER value to the current default, the peak
> > performance drops back to what we currently have (around 31
> > Gbps). In both these cases, there is no reallocation of skb since no
> > additional headroom is being requested and yet there is a
> > significant difference in performance.  I trying to figure out why
> > this is the case, your insights will be greatly appreciated.
> 
> It probably has something to do with cache line or data alignment.

Thanks David. I too am leaning towards the same conclusion. Since I am
not using any part of skb, it looks like the alignment issue is solved by
having a larger LL_MAX_HEADER (220 bytes to be specific). I will do some
bare metal testing on the setup we have and report back.

Regards,

K. Y 
