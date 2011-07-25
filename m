From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Mon, 25 Jul 2011 22:20:10 +1000
Message-ID: <20110725222010.0b284042@kryten>
References: <201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
	<201107222127.GBG51007.FStQFVOHOFOLJM@I-love.SAKURA.ne.jp>
	<201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp>
	<20110722.082224.688620059032914637.davem@davemloft.net>
	<4E2A7273.7030504@msgid.tls.msk.ru>
	<201107231939.FIF21882.QHOSOFtMFVLFOJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mjt@tls.msk.ru, davem@davemloft.net, casey@schaufler-ca.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107231939.FIF21882.QHOSOFtMFVLFOJ@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

> > (I noticed samba.org address in the Cc list).
> 
> That's because Anton Blanchard is author of sendmmsg() system call.

Ignore the From address - I wasn't adding sendmmsg with samba in mind.

> > When I saw recvmmsg()/sendmmsg() here, my first thought was an
> > authoritative DNS server which can read several requests at a
> > time and answer them all at once too - this way it all will go
> > to different addresses.
> 
> I don't know what application wants sendmmsg(). Since users can send
> up to UIO_MAXIOV (= 1024) "struct iovec" blocks using sendmsg(), they
> will use sendmsg() rather than sendmmsg() if the destination address
> are the same.

But if an application needs to maintain packet boundaries, then sendmsg
isn't going to help is it?
 
> Therefore, I guess users will use sendmmsg() for sending to multiple
> different destination addresses. If so, optimization based on
> destination address will do more harm than benefit; simply passing
> nosec flag down to LSM modules (so that SELinux will skip
> sock_has_perm() call and SMACK will not skip smack_netlabel_send()
> call) will be sufficient for 3.0.x stable release.
> 
> Anton, how do you want to use sendmmsg()?

I was using it for packet generation, using raw sockets.

Anton
