From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: What is lock_sock() before skb_free_datagram() for?
Date: Fri, 24 Apr 2009 06:56:52 +0900
Message-ID: <200904240656.JIC90182.HQOtLVJOFOMFFS@I-love.SAKURA.ne.jp>
References: <20090418.020837.106276006.davem@davemloft.net>
	<200904182123.HFF13509.MVSJtQHFLFOFOO@I-love.SAKURA.ne.jp>
	<20090418.212842.163717535.davem@davemloft.net>
	<200904191412.GIF95380.SVFJOHOFOQtLMF@I-love.SAKURA.ne.jp>
	<m2ab67to2w.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: sam@synack.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:60264 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbZDWV4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 17:56:55 -0400
In-Reply-To: <m2ab67to2w.fsf@ssh.synack.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Samir Bellabes wrote:
> what is the purpose of having such hooks ?
Same as security_socket_post_accept() (i.e. to drop datagrams from unwanted
peers).

I need to understand the meaning of "poll()" returning "ready" to understand
why security_socket_accept() and security_socket_recvmsg() are permitted to
return an error (though these hooks don't remove from the queue).

My understanding is that "poll()" returning "ready" does not guarantee that
accept()/recvmsg() shall return a valid file descriptor/datagram;
"poll()" returning "ready" guarantees merely accept()/recvmsg() does not
need to wait for connection/datagram. (Otherwise, security_socket_accept()
and security_socket_recvmsg() have to be gone.)
