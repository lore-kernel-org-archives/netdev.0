From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: optimize Berkeley Packet Filter (BPF) processing
Date: Sat, 19 Jun 2010 22:16:11 -0700
Message-ID: <20100619221611.784f7dbc@nehalam>
References: <1277003136-5522-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42198 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810Ab0FTFQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jun 2010 01:16:14 -0400
In-Reply-To: <1277003136-5522-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 20 Jun 2010 05:05:36 +0200
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> Gcc is currenlty not in the ability to optimize the switch statement in
> sk_run_filter() because of dense case labels. This patch replace the
> OR'd labels with ordered sequenced case labels. The sk_chk_filter()
> function is modified to patch/replace the original OPCODES in a
> ordered but equivalent form. gcc is now in the ability to transform the
> switch statement in sk_run_filter into a jump table of complexity O(1).
> 
> Until this patch gcc generates a sequence of conditional branches (O(n) of 567
> byte .text segment size (arch x86_64):

I don't think this works because it breaks ABI compatibility for applications tha
use older versions.
