From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH nf-next v2 1/2] netfilter: Fix potential null pointer dereference
Date: Wed, 28 Sep 2016 09:23:34 +0800
Message-ID: <CA+6hz4q_Fjc7mVZq7RG+RnioXFnD0w8Ows0AqwEy-5CJ7zg0yQ@mail.gmail.com>
References: <1474983515-4115-1-git-send-email-aconole@bytheb.org> <1474983515-4115-2-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474983515-4115-2-git-send-email-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Aaraon,

On Tue, Sep 27, 2016 at 9:38 PM, Aaron Conole <aconole@bytheb.org> wrote:
> It's possible for nf_hook_entry_head to return NULL if two
> nf_unregister_net_hook calls happen simultaneously with a single hook

The critical region of nf_unregister_net_hook is protected by &nf_hook_mutex.
When it would be called simultaneously?

Regards
Feng

> entry in the list.  This fix ensures that no null pointer dereference
> could occur when such a race happens.
>
> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> ---
>  net/netfilter/core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 360c63d..e58e420 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -160,7 +160,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>
>         mutex_lock(&nf_hook_mutex);
>         hooks_entry = nf_hook_entry_head(net, reg);
> -       if (hooks_entry->orig_ops == reg) {
> +       if (hooks_entry && hooks_entry->orig_ops == reg) {
>                 nf_set_hooks_head(net, reg,
>                                   nf_entry_dereference(hooks_entry->next));
>                 goto unlock;
> --
> 2.7.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
