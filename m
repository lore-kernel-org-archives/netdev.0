From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net-next PATCH 2/5] GSO: Add GSO type for fixed IPv4 ID
Date: Fri, 8 Apr 2016 18:41:00 -0300
Message-ID: <CAEh+42j21N+3ScmR9D9P3esgUL-G0kWxNT1x2zfGi_9M-bPKzw@mail.gmail.com>
References: <20160408203013.12838.63429.stgit@ahduyck-xeon-server> <20160408203318.12838.59720.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:34739 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759067AbcDHVlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 17:41:18 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 0839320328
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 21:41:17 +0000 (UTC)
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D7A91202EB
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 21:41:15 +0000 (UTC)
Received: by mail-qg0-f46.google.com with SMTP id f52so101691124qga.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 14:41:15 -0700 (PDT)
In-Reply-To: <20160408203318.12838.59720.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 8, 2016 at 5:33 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch adds support for TSO using IPv4 headers with a fixed IP ID
> field.  This is meant to allow us to do a lossless GRO in the case of TCP
> flows that use a fixed IP ID such as those that convert IPv6 header to IPv4
> headers.
>
> In addition I am adding a feature that for now I am referring to TSO with
> IP ID mangling.  Basically when this flag is enabled the device has the
> option to either output the flow with incrementing IP IDs or with a fixed
> IP ID regardless of what the original IP ID ordering was.  This is useful
> in cases where the DF bit is set and we do not care if the original IP ID
> value is maintained.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

I think SKB_GSO_TCP_FIXEDID would also need to be added to the list of
enumerated OK GSO types for MPLS GSO.
