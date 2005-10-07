From: Jouni Malinen <jkmaline-kf+aQKke1yb1KXRcyAk9cg@public.gmane.org>
Subject: Re: [PATCH SECURITY]: orinoco: Information leakage due to incorrect	padding
Date: Thu, 6 Oct 2005 20:25:37 -0700
Message-ID: <20051007032537.GB3936@jm.kir.nu>
References: <1128475990.11708.21.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: orinoco-devel <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Meder Kydyraliev <meder-ljIgrh4ImVw@public.gmane.org>
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1128475990.11708.21.camel@dv>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

On Tue, Oct 04, 2005 at 09:33:10PM -0400, Pavel Roskin wrote:

> orinoco: Information leakage due to incorrect padding
> 
> The orinoco driver can send uninitialized data exposing random pieces of
> the system memory.  This happens because data is not padded with zeroes
> when its length needs to be increased.

Issue itself looks valid in the current implementation, but a better fix
would be to just remove the padding.

> -	/* Length of the packet body */
> -	/* FIXME: what if the skb is smaller than this? */
> -	len = max_t(int,skb->len - ETH_HLEN, ETH_ZLEN - ETH_HLEN);
> +	/* Check packet length, pad short packets, round up odd length */
> +	len = max_t(int, ALIGN(skb->len, 2), ETH_ZLEN);
> +	if (skb->len < len) {
> +		skb = skb_padto(skb, len);

There is no ETH_ZLEN limit on IEEE 802.11 frames.

-- 
Jouni Malinen                                            PGP id EFC895FA


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
