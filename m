From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: Question regarding sendmmsg().
Date: Fri, 22 Jul 2011 21:27:02 +0900
Message-ID: <201107222127.GBG51007.FStQFVOHOFOLJM@I-love.SAKURA.ne.jp>
References: <201107110304.p6B34422036886@www262.sakura.ne.jp>
	<201107191754.22391.paul.moore@hp.com>
	<201107200142.p6K1gKYg077046@www262.sakura.ne.jp>
	<201107211721.14511.paul.moore@hp.com>
	<201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: casey@schaufler-ca.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107222041.FGG51092.OOQFFLOtMVFJHS@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote:
> According to http://ozlabs.org/~anton/junkcode/sendmmsg_test.c , the sendmmsg()
> introduced by commit 228e548e "net: Add sendmmsg socket system call" is capable
> of sending to multiple different destinations with single sendmmsg(), isn't it?
> 
> If yes, my plan (restricting sendmsg() based on destination's address) became
> impossible since security_socket_sendmsg() (which receives the destination's
> address) is called for only once even if there are multiple different
> destinations.

It seems to me that sendmmsg() caused a regression for SMACK.
SMACK implements security_socket_sendmsg() which uses destination address.

static int smack_socket_sendmsg(struct socket *sock, struct msghdr *msg,
                                int size)
{
        struct sockaddr_in *sip = (struct sockaddr_in *) msg->msg_name;

        /*
         * Perfectly reasonable for this to be NULL
         */
        if (sip == NULL || sip->sin_family != AF_INET)
                return 0;

        return smack_netlabel_send(sock->sk, sip);
}

I think SMACK wants to know all destination addresses as with TOMOYO.
