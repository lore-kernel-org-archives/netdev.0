From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/2] net: ovs: use CRC32
	accelerated flow hash if available
Date: Fri, 13 Dec 2013 10:01:20 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7487@saturn3.aculab.com>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com>
	<1386860946-1621-3-git-send-email-ffusco@redhat.com>
	<CAEP_g=-JBT_XVvwSa4xOwVoTysoL0Z8zJc-ERSHJc96+qrA99Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Jesse Gross" <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	"Francesco Fusco" <ffusco-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <CAEP_g=-JBT_XVvwSa4xOwVoTysoL0Z8zJc-ERSHJc96+qrA99Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Jesse Gross
...
> Out of curiosity, did you try using crc32q? OVS data structures are
> already aligned to 8 bytes. It would also be interesting to know if a
> parallelized implementation is worthwhile, although my guess is that
> the OVS flow key is not quite long enough.

My thoughts exactly.
Given this is a hash it could crc alternate words into separate
accumulators and the combine the values at the end.
That way you are still doing sequential accesses to the data.
(The crc instruction might be better than an xor for the combine.)
If the cpu has 3 execution units that can do crc, use them all.

It might be that the hash function is now an insignificant cost.
Looking at how much hashing the data twice (discarding the first
result - assign to global volatile data) slows things down can
help determine this.

	David
