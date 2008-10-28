From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/2] udp: introduce struct udp_table and multiple rwlocks
Date: Wed, 29 Oct 2008 00:31:18 +0300
Message-ID: <20081028213118.GB25217@ioremap.net>
References: <20081007160729.60c076c4@speedy> <20081007.135548.56141000.davem@davemloft.net> <48ECBBD8.9060602@cosmosbay.com> <20081008.114527.189056050.davem@davemloft.net> <4907780F.1080808@cosmosbay.com> <B7C6414D-7A69-48DA-8424-5D9F5FC50338@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Christian Bell <christian@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:37351 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752163AbYJ1VbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 17:31:20 -0400
Content-Disposition: inline
In-Reply-To: <B7C6414D-7A69-48DA-8424-5D9F5FC50338@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 02:23:55PM -0700, Christian Bell (christian@myri.com) wrote:
> >+	} else {
> >+		hslot = &udptable->hash[udp_hashfn(net, snum)];
> >+		write_lock_bh(&hslot->lock);
> >+		if (udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
> >+			goto fail;
> 
> The fail: label below should still unlock_bh when the above condition  
> fails.

This should be new label actually, since it is also used for non-locked
fail.

-- 
	Evgeniy Polyakov
