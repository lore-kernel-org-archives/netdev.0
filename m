From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] tcp: fix setting csum_start in tcp_gso_segment
Date: Tue, 24 Jun 2014 21:17:25 -0700
Message-ID: <CA+55aFxyZP_jXT-bLyFjJMp4WfVZp5vFtpu+-6_qCi46xkceQg@mail.gmail.com>
References: <alpine.DEB.2.02.1406242056330.29780@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:33886 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbaFYER0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 00:17:26 -0400
In-Reply-To: <alpine.DEB.2.02.1406242056330.29780@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 9:03 PM, Tom Herbert <therbert@google.com> wrote:
>
> It looks like a likely culprit is that SKB_GSO_CB()->csum_start is
> not set correctly when doing non-scatter gather. We are using
> offset as opposed to doffset.
>
> Reported-by: Dave Jones <davej@redhat.com>

DaveJ, I think you triggered this in five minutes on your box, and I
don't recall seeing anybody else reporting the oops (and google
doesn't find anything in the last month). So it's presumably somewhat
hw-specific. Does this fix the problem?

               Linus
