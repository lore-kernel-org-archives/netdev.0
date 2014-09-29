From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 30/34] net/netfilter/x_tables.c: use __seq_open_private()
Date: Mon, 29 Sep 2014 20:07:44 +0400
Message-ID: <542983D0.8060701@cogentembedded.com>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org> <1411994363-8451-31-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:38133 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754659AbaI2QHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 12:07:48 -0400
Received: by mail-lb0-f171.google.com with SMTP id l4so18371517lbv.30
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 09:07:47 -0700 (PDT)
In-Reply-To: <1411994363-8451-31-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/29/2014 04:39 PM, Pablo Neira Ayuso wrote:

> From: Rob Jones <rob.jones@codethink.co.uk>

> Reduce boilerplate code by using __seq_open_private() instead of seq_open()
> in xt_match_open() and xt_target_open().

> Signed-off-by: Rob Jones <rob.jones@codethink.co.uk>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>   net/netfilter/x_tables.c |   30 ++++--------------------------
>   1 file changed, 4 insertions(+), 26 deletions(-)

> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index 272ae4d..133eb47 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1101,22 +1101,11 @@ static const struct seq_operations xt_match_seq_ops = {
>
>   static int xt_match_open(struct inode *inode, struct file *file)
>   {
> -	struct seq_file *seq;
>   	struct nf_mttg_trav *trav;
> -	int ret;
> -

    Please don't remove this empty line after declaration.

> -	trav = kmalloc(sizeof(*trav), GFP_KERNEL);
> -	if (trav == NULL)
> +	trav = __seq_open_private(file, &xt_match_seq_ops, sizeof(*trav));
> +	if (!trav)
>   		return -ENOMEM;
>
> -	ret = seq_open(file, &xt_match_seq_ops);
> -	if (ret < 0) {
> -		kfree(trav);
> -		return ret;
> -	}
> -
> -	seq = file->private_data;
> -	seq->private = trav;
>   	trav->nfproto = (unsigned long)PDE_DATA(inode);
>   	return 0;
>   }
> @@ -1165,22 +1154,11 @@ static const struct seq_operations xt_target_seq_ops = {
>
>   static int xt_target_open(struct inode *inode, struct file *file)
>   {
> -	struct seq_file *seq;
>   	struct nf_mttg_trav *trav;
> -	int ret;
> -

    Likewise.

> -	trav = kmalloc(sizeof(*trav), GFP_KERNEL);
> -	if (trav == NULL)
> +	trav = __seq_open_private(file, &xt_target_seq_ops, sizeof(*trav));
> +	if (!trav)
>   		return -ENOMEM;

WBR, Sergei
