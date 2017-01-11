From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: Remove unused but set variable in
 __bpf_lru_list_shrink_inactive()
Date: Tue, 10 Jan 2017 16:25:23 -0800
Message-ID: <20170111002522.GB68360@ast-mbp.thefacebook.com>
References: <20170110140207.26480-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Martin KaFai Lau <kafai@fb.com>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35966 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934253AbdAKAZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 19:25:28 -0500
Received: by mail-pf0-f193.google.com with SMTP id b22so14659316pfd.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 16:25:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170110140207.26480-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 03:02:07PM +0100, Tobias Klauser wrote:
> Remove the unused but set variable 'first_node' in
> __bpf_lru_list_shrink_inactive() to fix the following GCC warning when
> building with 'W=1':
> 
>   kernel/bpf/bpf_lru_list.c:216:41: warning: variable ‘first_node’ set but not used [-Wunused-but-set-variable]
> 
> Cc: Martin KaFai Lau <kafai@fb.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  kernel/bpf/bpf_lru_list.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/kernel/bpf/bpf_lru_list.c b/kernel/bpf/bpf_lru_list.c
> index 89b7ef41c86b..d78501ee0609 100644
> --- a/kernel/bpf/bpf_lru_list.c
> +++ b/kernel/bpf/bpf_lru_list.c
> @@ -213,11 +213,10 @@ __bpf_lru_list_shrink_inactive(struct bpf_lru *lru,
>  			       enum bpf_lru_list_type tgt_free_type)
>  {
>  	struct list_head *inactive = &l->lists[BPF_LRU_LIST_T_INACTIVE];
> -	struct bpf_lru_node *node, *tmp_node, *first_node;
> +	struct bpf_lru_node *node, *tmp_node;
>  	unsigned int nshrinked = 0;
>  	unsigned int i = 0;
>  
> -	first_node = list_first_entry(inactive, struct bpf_lru_node, list);
>  	list_for_each_entry_safe_reverse(node, tmp_node, inactive, list) {
>  		if (bpf_lru_node_is_ref(node)) {
>  			__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_ACTIVE);

Martin,
I cannot tell whether it's actually copy-paste leftover
or this patch is needed:

diff --git a/kernel/bpf/bpf_lru_list.c b/kernel/bpf/bpf_lru_list.c
index 89b7ef41c86b..b9255a427c28 100644
--- a/kernel/bpf/bpf_lru_list.c
+++ b/kernel/bpf/bpf_lru_list.c
@@ -229,6 +229,7 @@ __bpf_lru_list_shrink_inactive(struct bpf_lru *lru,
                }

                if (++i == lru->nr_scans)
+               if (++i == lru->nr_scans || node == first_node)
                        break;
        }
