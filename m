From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net] net/neigh: move neigh cleanup routine to neigh_destroy
Date: Tue, 24 Apr 2012 13:05:09 +0300
Message-ID: <4F967AD5.3010807@mellanox.com>
References: <1335195282-28738-1-git-send-email-ogerlitz@mellanox.com> <20120424.005309.2292973770816115829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <shlomop@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:36598 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756606Ab2DXKFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 06:05:35 -0400
In-Reply-To: <20120424.005309.2292973770816115829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/2012 7:53 AM, David Miller wrote:
> With IPOIB, the neigh_cleanup purges references to the neigh when it 
> liberates the SKBs in the neigh resolution TX backlog during 
> ipoib_neigh_free(). Therefore, with your change, IPOIB neighs will 
> never be destroyed if they have any SKBs in their neigh resolution 
> queues. I'm not applying this, it's buggy. 

Oh yes indeed, so we will need to address that dependency too when 
coming to fix the ipoib neigh related races, thanks for spotting this over.

Or.
