From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Thu, 01 Aug 2013 10:48:31 +0800
Message-ID: <1375325311.7780.9.camel@cr0>
References: <1375238905-6423-1-git-send-email-amwang@redhat.com>
	 <1375240090.10515.53.camel@edumazet-glaptop> <1375240402.22980.5.camel@cr0>
	 <20130730.232639.178259761581407616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, ycheng@google.com, ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428Ab3HACsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 22:48:47 -0400
In-Reply-To: <20130730.232639.178259761581407616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-30 at 23:26 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed, 31 Jul 2013 11:13:22 +0800
> 
> > I know saving 8 bytes is not interesting for you, but it is for me,
> > since I need some room in struct tcp_metrics_block for union inet_addr.
> > With this patch, I don't have to make struct tcp_metrics_block expand to
> > 3 cachelines. :)
> 
> Cong, please.
> 
> Instead of making code accomodate an unnecessarily large "union
> inet_addr", make a small version of it that accomodates this use case
> and doesn't have the extra fields.

Please teach me how to do that?

The fields not used by inetpeer are sin_port and scope_id etc., and
sin_port is in the middle of sockaddr* structs.

Hmm, maybe just define a new struct by kicking the last field from
struct sockaddr_{in,in6}, so that we can at least shrink 4 bytes.

Except this, I have no idea how to do that.

Thanks!
