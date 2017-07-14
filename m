From: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net] openvswitch: Fix for force/commit action
	failures
Date: Fri, 14 Jul 2017 11:29:59 -0700
Message-ID: <CAPWQB7FxZa8=YCQj92+cOqNHoaBh8sO0b=0FW5=oj1SW7Q0eWQ@mail.gmail.com>
References: <1500048639-24169-1-git-send-email-gvrose8192@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Greg Rose <gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1500048639-24169-1-git-send-email-gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 14 July 2017 at 09:10, Greg Rose <gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> When there is an established connection in direction A->B, it is
> possible to receive a packet on port B which then executes
> ct(commit,force) without first performing ct() - ie, a lookup.
> In this case, we would expect that this packet can delete the existing
> entry so that we can commit a connection with direction B->A. However,
> currently we only perform a check in skb_nfct_cached() for whether
> OVS_CS_F_TRACKED is set and OVS_CS_F_INVALID is not set, ie that a
> lookup previously occurred. In the above scenario, a lookup has not
> occurred but we should still be able to statelessly look up the
> existing entry and potentially delete the entry if it is in the
> opposite direction.
>
> This patch extends the check to also hint that if the action has the
> force flag set, then we will lookup the existing entry so that the
> force check at the end of skb_nfct_cached has the ability to delete
> the connection.
>
> Fixes: dd41d330b03 ("openvswitch: Add force commit.")
> CC: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> CC: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> Signed-off-by: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
> Signed-off-by: Greg Rose <gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---

Thanks for the fix.

Reviewed-by: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
