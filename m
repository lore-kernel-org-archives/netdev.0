From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: netif_napi_add vs. multiple netdev's
Date: Tue, 16 Oct 2007 09:10:35 -0700
Message-ID: <20071016091035.5fcd6d2e@freepuppy.rosehill>
References: <1192513633.19073.21.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39789 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750827AbXJPQKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 12:10:45 -0400
In-Reply-To: <1192513633.19073.21.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Oct 2007 15:47:13 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> Hi Stehphen !
> 
> The new netif_napi_add() function takes a netdev argument. In the EMAC
> case, there is one NAPI instance working on behalf of multiple netdev's,
> so that isn't very useful. For my EMAC patch (just posted to you & the
> list), I'm not passing NULL, but I'm wondering what would be a good way
> to handle netpoll here...

The problem is that netpoll only has a handle to the device being used
as a netconsole, but may need to activate the NAPI poll routine to
cleanup state. Perhaps teaching netpoll about N to 1 mappings would
be better.

> 
> The way it's currently implemented, there's a list of NAPI's attached to
> the netdev, so obviously, that won't work for my usage scenario.

sky2 driver has potentially 2 ports for 1 NAPI instance.

> I'm not sure what's the best data structure that would be suitable for
> both N ndev's for 1 NAPI and 1 ndev for N NAPI's though... I could
> allocate "stub" list heads and queue those up, but that's a bit gross...

The new interface doesn't change anything. The old code had the
same problem vis-a-vis netpoll.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
