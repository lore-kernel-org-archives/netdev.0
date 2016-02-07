From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: support for static fdb entries
Date: Sun, 7 Feb 2016 11:41:57 -0800
Message-ID: <20160207114157.3dd8fe4f@xeon-e3>
References: <1453914577-43389-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wkok@cumulusnetworks.com,
	scotte@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	makita.toshiaki@lab.ntt.co.jp
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34707 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754511AbcBGTlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:41:44 -0500
Received: by mail-pa0-f42.google.com with SMTP id uo6so63365269pac.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 11:41:44 -0800 (PST)
In-Reply-To: <1453914577-43389-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Jan 2016 09:09:37 -0800
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> There is no intuitive option to add static fdb entries today.
> 'temp' seems to have a side effect of adding
> 'static' fdb entries. But the name and intent
> of 'temp' does not say anything about it being static.
> 
> example:
> bridge fdb add operates as follows:
> 
> $bridge fdb add 00:01:02:03:04:05 dev eth0 master
> $bridge fdb add 00:01:02:03:04:06 dev eth0 master temp
> $bridge fdb add 00:01:02:03:04:07 dev eth0 master local
> 
> $bridge fdb show
> 00:01:02:03:04:05 dev eth0 permanent
> 00:01:02:03:04:06 dev eth0 static
> 00:01:02:03:04:07 dev eth0 permanent
> 00:01:02:03:04:08 dev eth0 <<== dynamic, ageable learned mac
> 
> This patch adds a new bridge fdb type 'static' which
> makes sure NUD_NOARP and NUD_REACHABLE is set for static
> entries. This effectively is nothing but what 'temp'
> does today. But the name 'temp' is misleading.
> 
> After the patch:
> $bridge fdb add 00:01:02:03:04:06 dev eth0 master static
> 
> $bridge fdb show
> 00:01:02:03:04:06 dev eth0 static
> 
> 'temp' could ideally be a dynamic mac that can age (ie just
> NUD_REACHABLE). But, 'temp' sets 'NUD_NOARP' and 'NUD_REACHABLE'.
> Too late to change 'temp' now. But, we are thinking of introduing a
> 'dynamic' keyword after this patch that only sets NUD_REACHABLE.
> 
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> Will submit another patch to document bridge fdb options
> once we agree on the behaviour and this patch is accepted.
> 
>  bridge/fdb.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

Appled.
Please update man page
