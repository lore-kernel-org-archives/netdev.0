From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next v3 1/2] ipv6: start fib6 gc on RTF_CACHE dst
 creation
Date: Thu, 19 Oct 2017 14:01:47 -0700
Message-ID: <20171019210147.mbmtyhk55b4jpk6q@kafai-mbp.dhcp.thefacebook.com>
References: <cover.1508421311.git.pabeni@redhat.com>
 <f699f29b3fb7675fdfe5d85ab39e153c147c12f8.1508421311.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60834 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752467AbdJSVB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 17:01:57 -0400
Content-Disposition: inline
In-Reply-To: <f699f29b3fb7675fdfe5d85ab39e153c147c12f8.1508421311.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 02:07:10PM +0000, Paolo Abeni wrote:
> After the commit 2b760fcf5cfb ("ipv6: hook up exception table
> to store dst cache"), the fib6 gc is not started after the
> creation of a RTF_CACHE via a redirect or pmtu update, since
> fib6_add() isn't invoked anymore for such dsts.
> 
> We need the fib6 gc to run periodically to clean the RTF_CACHE,
> or the dst will stay there forever.
> 
> Fix it by explicitly calling fib6_force_start_gc() on successful
> exception creation. gc_args->more accounting will ensure that
> the gc timer will run for whatever time needed to properly
> clean the table.
> 
> v2 -> v3:
>  - clarified the commit message
> 
> Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
