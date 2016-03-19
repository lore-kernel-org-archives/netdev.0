From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 9/9] ixgbe/ixgbevf: Add support for GSO partial
Date: Fri, 18 Mar 2016 19:05:43 -0700
Message-ID: <CAEh+42hwfx6EEbE9pf6RFdL9xkcc60CbguSFm+c+QDa63UMymA@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain> <20160318232535.14955.19028.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:38747 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538AbcCSCGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 22:06:01 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 0E39720435
	for <netdev@vger.kernel.org>; Sat, 19 Mar 2016 02:06:00 +0000 (UTC)
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8F60E20429
	for <netdev@vger.kernel.org>; Sat, 19 Mar 2016 02:05:58 +0000 (UTC)
Received: by mail-qg0-f43.google.com with SMTP id u110so115335747qge.3
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 19:05:58 -0700 (PDT)
In-Reply-To: <20160318232535.14955.19028.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 4:25 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch adds support for partial GSO segmentation in the case of GRE or
> UDP encapsulated frames.
>
> The one bit in this patch that is a bit controversial is the fact that we
> are leaving the inner IPv4 IP ID as a static value in the case of
> segmentation.  As per RFC6864 this should be acceptable as TCP frames set
> the DF bit so the IP ID should be ignored.  However this is not always the
> case as header compression schemes for PPP and SLIP can end up taking a
> performance hit as they have to record the fact that the ID didn't change
> as expected.
>
> In addition GRO was examining the IP ID field as well.  As such on older
> GRO implementations TSO frames from this driver may end up blocking GRO on
> the other end which will likely hurt performance instead of helping it.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

I wasn't able to apply this patch, it seems like it might be based on
some Intel driver patches that haven't been merged into net-next yet?
