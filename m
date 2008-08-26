From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] [PATCH] sctp: add verification checks to SCTP_AUTH_KEY
 option
Date: Mon, 25 Aug 2008 18:28:32 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808251827240.3363@nehalem.linux-foundation.org>
References: <20080825164440.GA504@kernel.sg> <12196959323990-git-send-email-vladislav.yasevich@hp.com> <48B35561.2010001@redhat.com> <alpine.LFD.1.10.0808251816110.3363@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, security@kernel.org,
	davem@davemloft.net
To: Eugene Teo <eteo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36587 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753681AbYHZB3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 21:29:25 -0400
In-Reply-To: <alpine.LFD.1.10.0808251816110.3363@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 25 Aug 2008, Linus Torvalds wrote:
> 
> But if it can overflow, I actually think it makes more sense to test for 
> something smaller than the "exact" overflow. A key can't reasonably be all 
> that long _anyway_, so it's probably better to test for something _much_ 
> smaller.

IOW, I think it would make _more_ sense to just declare some "key size 
max", and do something like

	#define SCTP_AUTH_KEY_SIZE (65536)

	.. 
	if (key_len > SCTP_AUTH_KEY_SIZE)
		return -EINVAL;

kind of thing.

		Linus
