From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Wed, 26 Oct 2016 10:41:55 +0200
Message-ID: <20161026084155.GA16001@pox.localdomain>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34864 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752781AbcJZIl6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 04:41:58 -0400
Received: by mail-wm0-f51.google.com with SMTP id e69so11654971wmg.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 01:41:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/16 at 03:30pm, David Ahern wrote:
> @@ -171,6 +177,9 @@ int __cgroup_bpf_run_filter(struct sock *sk,
>  		case BPF_CGROUP_INET_EGRESS:
>  			ret = __cgroup_bpf_run_filter_skb(skb, prog);
>  			break;
> +		case BPF_CGROUP_INET_SOCK_CREATE:
> +			ret = __cgroup_bpf_run_filter_sk_create(sk, prog);
> +			break;
>  		/* make gcc happy else complains about missing enum value */
>  		default:
>  			return 0;

Thinking further ahead of your simple example. Instead of adding yet
another prog type for the same hook, we can make this compatible with
BPF_CGROUP_INET_EGRESS instead which would then provide a ctx which
contains both, the sk and skb.

The ctx concept is very flexible. We can keep the existing dummy skb
representation and add sk_ fields which are only valid for BPF at
socket layer, e.g skb->sk_bound_dev_if would translate to
sk->bound_dev_if.
