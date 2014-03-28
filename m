From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net v2] openvswitch: fix a possible deadlock
 and lockdep warning
Date: Fri, 28 Mar 2014 16:42:42 -0400 (EDT)
Message-ID: <20140328.164242.318154109747795081.davem@davemloft.net>
References: <1395929134-4487-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395929134-4487-1-git-send-email-fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Thu, 27 Mar 2014 11:05:34 -0300

> There are two problematic situations.
> 
> A deadlock can happen when is_percpu is false because it can get
> interrupted while holding the spinlock. Then it executes
> ovs_flow_stats_update() in softirq context which tries to get
> the same lock.
> 
> The second sitation is that when is_percpu is true, the code
> correctly disables BH but only for the local CPU, so the
> following can happen when locking the remote CPU without
> disabling BH:
 ...
> Signed-off-by: Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  v2: better commit message

Ok, I just saw Jesse's request that I apply this directly, so I
have done so.

Thanks.
