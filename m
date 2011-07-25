From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Mon, 25 Jul 2011 22:15:40 +0900
Message-ID: <201107252215.GBG95887.OQVMFOOJLSFFHt@I-love.SAKURA.ne.jp>
References: <201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp>
	<20110722.082224.688620059032914637.davem@davemloft.net>
	<4E2A7273.7030504@msgid.tls.msk.ru>
	<201107231939.FIF21882.QHOSOFtMFVLFOJ@I-love.SAKURA.ne.jp>
	<20110725222010.0b284042@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mjt@tls.msk.ru, davem@davemloft.net, casey@schaufler-ca.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: anton@samba.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110725222010.0b284042@kryten>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
> > > When I saw recvmmsg()/sendmmsg() here, my first thought was an
> > > authoritative DNS server which can read several requests at a
> > > time and answer them all at once too - this way it all will go
> > > to different addresses.
> > 
> > I don't know what application wants sendmmsg(). Since users can send
> > up to UIO_MAXIOV (= 1024) "struct iovec" blocks using sendmsg(), they
> > will use sendmsg() rather than sendmmsg() if the destination address
> > are the same.
> 
> But if an application needs to maintain packet boundaries, then sendmsg
> isn't going to help is it?

Well, such application might want to use RDM or SeqPacket... but your point is
to maintain packet boundaries. You are assuming that sendmmsg() will be used
for sending as much data as possible while preserving packet boundaries.

OK. Then, the question is how to reduce performance loss by redundant
security_socket_sendmsg() calls. If sendmmsg() likely contains single (or few)
destination(s), trying to optimize security_socket_sendmsg() calls by comparing
destination address (as proposed at
http://www.spinics.net/linux/fedora/linux-security-module/msg11510.html
) would help. Otherwise, no optimization (as proposed at
http://www.spinics.net/linux/fedora/linux-security-module/msg11504.html
) would be better. Which approach do you like?
