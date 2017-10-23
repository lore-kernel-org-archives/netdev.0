From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: add ip6_null_entry check in rt6_select()
Date: Mon, 23 Oct 2017 15:27:20 -0700
Message-ID: <20171023222720.devlgh6xh2upeepb@kafai-mbp.dhcp.thefacebook.com>
References: <20171023215935.52136-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33090 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751113AbdJWW12 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:27:28 -0400
Content-Disposition: inline
In-Reply-To: <20171023215935.52136-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 09:59:35PM +0000, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
> 
> In rt6_select(), fn->leaf could be pointing to net->ipv6.ip6_null_entry.
> In this case, we should directly return instead of trying to carry on
> with the rest of the process.
> If not, we could crash at:
>   spin_lock_bh(&leaf->rt6i_table->rt6_lock);
> because net->ipv6.ip6_null_entry does not have rt6i_table set.
Make sense. leaf->rt6i_table->rt6_lock is only needed after the rcu work.

Thanks for fixing it!

Acked-by: Martin KaFai Lau <kafai@fb.com>
