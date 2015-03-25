From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] ipv4: hash net ptr into fragmentation
 bucket selection
Date: Wed, 25 Mar 2015 08:34:13 -0700
Message-ID: <1427297653.25985.116.camel@edumazet-glaptop2.roam.corp.google.com>
References: <748d8e27361f8c77fe8ade5f05fbfd2b86371e22.1427293098.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Flavio Leitner <fbl@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38668 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbbCYPeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:34:16 -0400
Received: by igbqf9 with SMTP id qf9so28540871igb.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 08:34:15 -0700 (PDT)
In-Reply-To: <748d8e27361f8c77fe8ade5f05fbfd2b86371e22.1427293098.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-25 at 15:18 +0100, Hannes Frederic Sowa wrote:

>  	hash = jhash_3words((__force u32)iph->daddr,
>  			    (__force u32)iph->saddr,
> -			    iph->protocol,
> +			    iph->protocol | (net_hash_mix(net) << 8),
>  			    ip_idents_hashrnd);


I would rather use 

iph->protocol ^ net_hash_mix(net)
