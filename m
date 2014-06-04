From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH urgent] netlink: Only check file credentials for
 implicit destinations
Date: Wed, 4 Jun 2014 18:01:31 +0200
Message-ID: <20140604180131.1bc17fe8@griffin>
References: <06bbac8182aa1054ab8f6392f14e9148def0f561.1401472882.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45825 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbaFDQBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 12:01:36 -0400
In-Reply-To: <06bbac8182aa1054ab8f6392f14e9148def0f561.1401472882.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 May 2014 11:04:00 -0700, Andy Lutomirski wrote:
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1373,7 +1373,9 @@ retry:
>  bool __netlink_ns_capable(const struct netlink_skb_parms *nsp,
>  			struct user_namespace *user_ns, int cap)
>  {
> -	return sk_ns_capable(nsp->sk, user_ns, cap);
> +	return ((nsp->flags & NETLINK_SKB_DST) ||
> +		file_ns_capable(nsp->sk->sk_socket->file, user_ns, cap)) &&
> +		ns_capable(user_ns, cap);

Sorry if I'm missing something. Is socket->file valid (non-NULL) in
kernel->kernel netlink communication? I don't think it's assigned for
sockets created by netlink_kernel_create, is it? Seems this would cause
NULL ptr dereference.

But then, I don't even know whether kernel->kernel netlink
communication is allowed.

(I'm aware that if this is really the case the NULL ptr deref is not
caused by this patch but by the one this is fixing.)

Thanks,

 Jiri

-- 
Jiri Benc
