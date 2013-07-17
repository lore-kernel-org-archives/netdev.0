From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v3] xen-netfront: pull on receive skb may need to happen
 earlier
Date: Wed, 17 Jul 2013 09:26:24 +0100
Message-ID: <1374049584.4663.64.camel@kazak.uk.xensource.com>
References: <51E5327902000078000E5426@nat28.tlf.novell.com>
	 <1373970815.4663.45.camel@kazak.uk.xensource.com>
	 <51E65F5102000078000E57ED@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Wei Liu <wei.liu2@citrix.com>,
	Dion Kant <g.w.kant@hunenet.nl>,
	xen-devel <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <51E65F5102000078000E57ED@nat28.tlf.novell.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-17 at 08:09 +0100, Jan Beulich wrote:
> Due to commit 3683243b ("xen-netfront: use __pskb_pull_tail to ensure
> linear area is big enough on RX") xennet_fill_frags() may end up
> filling MAX_SKB_FRAGS + 1 fragments in a receive skb, and only reduce
> the fragment count subsequently via __pskb_pull_tail(). That's a
> result of xennet_get_responses() allowing a maximum of one more slot to
> be consumed (and intermediately transformed into a fragment) if the
> head slot has a size less than or equal to RX_COPY_THRESHOLD.
> 
> Hence we need to adjust xennet_fill_frags() to pull earlier if we
> reached the maximum fragment count - due to the described behavior of
> xennet_get_responses() this guarantees that at least the first fragment
> will get completely consumed, and hence the fragment count reduced.
> 
> In order to not needlessly call __pskb_pull_tail() twice, make the
> original call conditional upon the pull target not having been reached
> yet, and defer the newly added one as much as possible (an alternative
> would have been to always call the function right before the call to
> xennet_fill_frags(), but that would imply more frequent cases of
> needing to call it twice).
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> Acked-by: Wei Liu <wei.liu2@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Ian.
