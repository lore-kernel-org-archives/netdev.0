From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net 2/3] sched: cls_flower: fix panic on filter replace
Date: Sat, 18 Jul 2015 22:37:36 +0200
Message-ID: <20150718203736.GA2121@nanopsycho.orion>
References: <cover.1437163466.git.daniel@iogearbox.net>
 <65e84800671280bdf16ea28f71ecef3d5fcecccc.1437163466.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@plumgrid.com, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34100 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbbGRUhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 16:37:40 -0400
Received: by wibud3 with SMTP id ud3so61395695wib.1
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 13:37:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <65e84800671280bdf16ea28f71ecef3d5fcecccc.1437163466.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 17, 2015 at 10:38:44PM CEST, daniel@iogearbox.net wrote:
>The following test case causes a NULL pointer dereference in cls_flower:
>
>  tc filter add dev foo parent 1: flower eth_type ipv4 action ok flowid 1:1
>  tc filter replace dev foo parent 1: pref 49152 handle 0x1 \
>            flower eth_type ipv6 action ok flowid 1:1
>
>The problem is that commit 77b9900ef53a ("tc: introduce Flower classifier")
>accidentally swapped the arguments of list_replace_rcu(), the old
>element needs to be the first argument and the new element the second.
>
>Fixes: 77b9900ef53a ("tc: introduce Flower classifier")
>Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>


Acked-by: Jiri Pirko <jiri@resnulli.us>
