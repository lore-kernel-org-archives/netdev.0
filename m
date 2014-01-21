From: Michal Sekletar <msekleta@redhat.com>
Subject: Re: [PATCH net-next] net: filter: let bpf_tell_extensions return
 SKF_AD_MAX
Date: Tue, 21 Jan 2014 15:25:42 +0100
Message-ID: <20140121142542.GI5206@loki.brq.redhat.com>
References: <1390259977-28770-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754472AbaAUOZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:25:48 -0500
Content-Disposition: inline
In-Reply-To: <1390259977-28770-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 21, 2014 at 12:19:37AM +0100, Daniel Borkmann wrote:
> Michal Sekletar added in commit ea02f9411d9f ("net: introduce
> SO_BPF_EXTENSIONS") a facility where user space can enquire
> the BPF ancillary instruction set, which is imho a step into
> the right direction for letting user space high-level to BPF
> optimizers make an informed decision for possibly using these
> extensions.
> 
> The original rationale was to return through a getsockopt(2)
> a bitfield of which instructions are supported and which
> are not, as of right now, we just return 0 to indicate a
> base support for SKF_AD_PROTOCOL up to SKF_AD_PAY_OFFSET.
> Limitations of this approach are that this API which we need
> to maintain for a long time can only support a maximum of 32
> extensions, and needs to be additionally maintained/updated
> when each new extension that comes in.
> 
> I thought about this a bit more and what we can do here to
> overcome this is to just return SKF_AD_MAX. Since we never
> remove any extension since we cannot break user space and
> always linearly increase SKF_AD_MAX on each newly added
> extension, user space can make a decision on what extensions
> are supported in the whole set of extensions and which aren't,
> by just checking which of them from the whole set have an
> offset < SKF_AD_MAX of the underlying kernel.
> 
> Since SKF_AD_MAX must be updated each time we add new ones,
> we don't need to introduce an additional enum and got
> maintenance for free. At some point in time when
> SO_BPF_EXTENSIONS becomes ubiquitous for most kernels, then
> an application can simply make use of this and easily be run
> on newer or older underlying kernels without needing to be
> recompiled, of course. Since that is for 3.14, it's not too
> late to do this change.
> 
> Cc: Michal Sekletar <msekleta@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/linux/filter.h | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 1a95a2d..e568c8e 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -85,13 +85,7 @@ static inline void bpf_jit_free(struct sk_filter *fp)
>  
>  static inline int bpf_tell_extensions(void)
>  {
> -	/* When adding new BPF extension it is necessary to enumerate
> -	 * it here, so userspace software which wants to know what is
> -	 * supported can do so by inspecting return value of this
> -	 * function
> -	 */
> -
> -	return 0;
> +	return SKF_AD_MAX;
>  }
>  
>  enum {
> -- 
> 1.8.3.1
> 
Acked-by: Michal Sekletar <msekleta@redhat.com>

Thanks!
