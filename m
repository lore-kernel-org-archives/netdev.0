From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] xtables: zero padding in data_to_user
Date: Mon, 15 May 2017 18:52:22 +0200
Message-ID: <20170515165222.GA3986@salvia>
References: <20170509201737.102987-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        rgb@redhat.com, fwestpha@redhat.com, pmoore@redhat.com,
        pvrabec@redhat.com, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:54603 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965996AbdEOQwc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 12:52:32 -0400
Content-Disposition: inline
In-Reply-To: <20170509201737.102987-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 09, 2017 at 04:17:37PM -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> When looking up an iptables rule, the iptables binary compares the
> aligned match and target data (XT_ALIGN). In some cases this can
> exceed the actual data size to include padding bytes.
> 
> Before commit f77bc5b23fb1 ("iptables: use match, target and data
> copy_to_user helpers") the malloc()ed bytes were overwritten by the
> kernel with kzalloced contents, zeroing the padding and making the
> comparison succeed. After this patch, the kernel copies and clears
> only data, leaving the padding bytes undefined.
> 
> Extend the clear operation from data size to aligned data size to
> include the padding bytes, if any.
> 
> Padding bytes can be observed in both match and target, and the bug
> triggered, by issuing a rule with match icmp and target ACCEPT:
> 
>   iptables -t mangle -A INPUT -i lo -p icmp --icmp-type 1 -j ACCEPT
>   iptables -t mangle -D INPUT -i lo -p icmp --icmp-type 1 -j ACCEPT

Applied, thanks.
