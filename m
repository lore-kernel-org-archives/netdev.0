From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 02:10:33 +0200
Message-ID: <554172F9.7040002@iogearbox.net>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org> <1430333589-4940-7-git-send-email-pablo@netfilter.org> <55413E99.5000807@iogearbox.net> <20150429233205.GA3416@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37050 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbbD3AKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 20:10:40 -0400
In-Reply-To: <20150429233205.GA3416@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 01:32 AM, Pablo Neira Ayuso wrote:
...
> Actually, the extra cost is roughly (getting inlined stuff away and
> other non-relevant stuff):
>
>      `-> nf_hook_slow()
>       `-> [for each entry in hook list]
>        `-> nf_iterate()
>         `-> (*elemp)->hook()

Yep, agreed.

> as part of the generic hook infrastructure, which comes with extra
> flexibility in return. I think the main concern so far was not to harm
> the critical netif_receive_core() path, and this patchset proves not
> to affect this.

Correct, as you use the static key and hide everything behind it.
