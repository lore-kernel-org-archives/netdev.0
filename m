From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process'ssecurity context.
Date: Fri, 30 Nov 2007 23:07:19 +0900
Message-ID: <200711302307.EJD21822.JFFMQFSOOHLtVO@I-love.SAKURA.ne.jp>
References: <200711212130.EJJ43745.LFOFHOSMJOtFVQ@I-love.SAKURA.ne.jp>
	<200711222235.GCA05378.HtMOJQVFSFOLFO@I-love.SAKURA.ne.jp>
	<Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
	<200711241114.FCJ30702.JSMOFQtVHFFOOL@I-love.SAKURA.ne.jp>
	<m2sl2p8x8e.fsf@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-security-module@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, sds@tycho.nsa.gov
To: sam@synack.fr
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m2sl2p8x8e.fsf@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Thank you for feedback.

I have some questions.

(1) Your module uses "struct security_operations" and
    is registered with register_security().

    TOMOYO also uses "struct security_operations" and
    must be registered with register_security().

    Can your module and TOMOYO coexist?

(2) Can your module handle incoming UDP's datagram too?

(3) How do you handle race window between security_socket_accept()
    and sock->ops->accept()?

Samir Bellabes wrote:
> My approach is to get the informations regarding the socket from
> socket(), bind() and and accept() syscalls hooks.
> Pushing this informations to userspace. Here the user can refuse or
> accept the sycalls.

    If a socket is shared by multiple processes and
    the user said "Accept this connection" at security_socket_accept(),
    the process does not always pick up what the user wanted to pick up
    because there is no mutex between security_socket_accept() and
    sock->ops->accept().

(4) If (3) is my misunderstanding (i.e. the user doesn't judge at security_socket_accept()),
    it means that the user judges it before select() says "ready to accept".
    Then ... what happens if a socket is shared by multiple programs?
    The user has to judge without knowing which program will pick up this connection.
    TOMOYO lets the user judge whether to accept or not
    with knowing the program's name who picks up this connection.

I think getting information at socket(), bind() and accept() is helpful for detailed judgement,
but I think it doesn't solve race problem as long as the user judges *before* sock->ops->accept().

Regards.

