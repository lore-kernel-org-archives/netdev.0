From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 11 Aug 2008 16:33:43 -0500
Message-ID: <48A0B037.501@linux-foundation.org>
References: <48A086B6.2000901@linux-foundation.org> <20080811.141501.01468546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33802 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754882AbYHKVeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 17:34:19 -0400
In-Reply-To: <20080811.141501.01468546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> Isn't that when some major scheduler changes went in?  I'm not blaming
> the scheduler, but rather I'm making the point that there are other
> subsystems in the kernel that the networking interacts with that
> influences performance at such a low level.  This includes the memory
> allocator :-)

Right this covers a significant portion of the kernel. SLAB was used since .22
was pretty early for SLUB. And around 2.6.24 we had the merges of the antifrag
logic.

.25 was the point where HR timers came in. By switching off hrtimers I can get
some (minor) portion of performance back. There must be more things in play
though.

Maybe what we are seeing is general bloat in kernel execution paths due to the
growth in complexity?
