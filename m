From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2 net-next] openvswitch: Use skb_zerocopy()
 for upcall
Date: Fri, 08 Nov 2013 12:24:21 +0100
Message-ID: <527CC9E5.2070303@redhat.com>
References: <cover.1383906944.git.tgraf@suug.ch>
	<9369d871e13fe5b6e468b269450b9f2032a970aa.1383906944.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <9369d871e13fe5b6e468b269450b9f2032a970aa.1383906944.git.tgraf-G/eBtMaohhA@public.gmane.org>
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

On 11/08/2013 11:47 AM, Thomas Graf wrote:
> Use of skb_zerocopy() avoids the expensive call to memcpy() when
> copying the packet data into the Netlink skb. Completes checksum
> through skb_checksum_help() if needed.
>
> Netlink messaged must be properly padded and aligned to meet
> sanity checks of the user space counterpart.
>
> Cost of memcpy is significantly reduced from:
> +   7.48%       vhost-8471  [k] memcpy
> +   5.57%     ovs-vswitchd  [k] memcpy
> +   2.81%       vhost-8471  [k] csum_partial_copy_generic
>
> to:
> +   5.72%     ovs-vswitchd  [k] memcpy
> +   3.32%       vhost-5153  [k] memcpy
> +   0.68%       vhost-5153  [k] skb_zerocopy
>
> (megaflows disabled)
>
> Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> Cc: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Reviewed-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
