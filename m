From: Paul Moore <paul.moore@hp.com>
Subject: Re: Question regarding sendmmsg().
Date: Tue, 26 Jul 2011 16:30:44 -0400
Message-ID: <201107261630.44942.paul.moore@hp.com>
References: <201107110304.p6B34422036886@www262.sakura.ne.jp> <201107211721.14511.paul.moore@hp.com> <201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, July 22, 2011 7:41:20 AM Tetsuo Handa wrote:
> TOMOYO was about to add support for permission checks for
> PF_INET/PF_INET6/PF_UNIX socket's bind()/listen()/connect()/send()
> operations (
> http://www.spinics.net/linux/fedora/linux-security-module/msg11496.html ).
> 
> According to http://ozlabs.org/~anton/junkcode/sendmmsg_test.c , the
> sendmmsg() introduced by commit 228e548e "net: Add sendmmsg socket system
> call" is capable of sending to multiple different destinations with single
> sendmmsg(), isn't it?

I believe so, yes.

> If yes, my plan (restricting sendmsg() based on destination's address)
> became impossible since security_socket_sendmsg() (which receives the
> destination's address) is called for only once even if there are multiple
> different destinations.

We could always change this behavior so that the sendmsg() LSM hook is called 
for each msg sent, but there would be a performance impact associated with it. 

We decided that it was unnecessary to do it this way earlier because there was 
no need: SELinux and Smack both treat the socket as an endpoint (from a 
implementation point of view only, from a high level design Smack doesn't care 
about sockets) and AppArmor really doesn't have much in the way of network 
access controls at present.

--
paul moore
linux @ hp
