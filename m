From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 4/4] net: af_unix: implement splice for
 stream af_unix sockets
Date: Thu, 21 May 2015 07:23:18 -0700
Message-ID: <1432218198.4060.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1432200343.git.hannes@stressinduktion.org>
	 <1cd0796801936fb583e66a719597035ea779f534.1432200344.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, cwang@twopensource.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34494 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754189AbbEUOXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 10:23:20 -0400
Received: by igbhj9 with SMTP id hj9so11402748igb.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 07:23:20 -0700 (PDT)
In-Reply-To: <1cd0796801936fb583e66a719597035ea779f534.1432200344.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 11:39 +0200, Hannes Frederic Sowa wrote:
> unix_stream_recvmsg is refactored to unix_stream_read_generic in this
> patch and enhanced to deal with pipe splicing. The refactoring is
> inneglible, we mostly have to deal with a non-existing struct msghdr
> argument.
> 

> +static __always_inline
> +int unix_stream_read_generic(struct unix_stream_read_state *state)
>  {


I do not believe it is reasonable to inline this monster, even if some
macro benchmark looks better.

General trend in the community is to remove all these inlines.

ip_finish_output2() for example should lose its 'inline' keyword.
