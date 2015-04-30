From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 02:00:21 +0200
Message-ID: <55417095.9030202@iogearbox.net>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org> <1430333589-4940-7-git-send-email-pablo@netfilter.org> <55413E99.5000807@iogearbox.net> <20150429233600.GA7025@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36683 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbbD3AA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 20:00:28 -0400
In-Reply-To: <20150429233600.GA7025@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 01:36 AM, Patrick McHardy wrote:
...
> You obviously realize this callchain is fully made up by yourself

Hence, I wrote path, not call chain, I guess that should have been
clear.

[...]
> The difference is very simple: where we had an indirect call to
> q->enqueue before (and a lot of crap that didn't belong there),
> we now have a call to nf_hook_slow, followed by the hook invocation.

Sure, but what I wanted to express is that from an architectural
point of view down to invoking a classifier, we now have a list of
hooks, one element of those can be ingress qdisc and that one can
have lists of classifier/actions by itself, etc. That doesn't seem
sound wrt 'where it really belongs'.

Personally, I have no objections if you want to use netfilter on
ingress, don't get me wrong, but that ingress qdisc part doesn't
really fit in there, and moving it behind netfilter facilities does
have additional cost for a packet.
