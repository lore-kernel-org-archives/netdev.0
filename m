From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC 2/9] Revert "lsm: Remove the socket_post_accept() hook"
Date: Tue, 05 Jan 2010 09:31:43 +0900
Message-ID: <201001050031.o050VhTU002668@www262.sakura.ne.jp>
References: <1262437456-24476-1-git-send-email-sam@synack.fr> <1262437456-24476-3-git-send-email-sam@synack.fr> <20100104183619.GA6034@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: serue@us.ibm.com, linux-security-module@vger.kernel.org,
	kaber@trash.net, hadi@cyberus.ca, zbr@ioremap.net,
	nhorman@tuxdriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: sam@synack.fr
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100104183619.GA6034@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Samir Bellabes (sam@synack.fr):
> > This reverts commit 8651d5c0b1f874c5b8307ae2b858bc40f9f02482.
> > 
> > snet needs to reintroduce this hook, as it was designed to be: a hook for
> > updating security informations on objects.
> > 
> > Signed-off-by: Samir Bellabes <sam@synack.fr>
> 
> Acked-by: Serge Hallyn <serue@us.ibm.com>
> 
> (contingent of course on the proposed user actually going in :)
> 
> > diff --git a/net/socket.c b/net/socket.c
> > index 8984973..fcd4f2b 100644
> > --- a/net/socket.c
> > +++ b/net/socket.c
> > @@ -1557,6 +1557,8 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
> >  	fd_install(newfd, newfile);
> >  	err = newfd;
> > 
> > +	security_socket_post_accept(sock, newsock);
> > +
> >  out_put:
> >  	fput_light(sock->file, fput_needed);
> >  out:

I think we should call security_socket_post_accept() before fd_install().
Otherwise, other threads which share fd tables can use
security-informations-not-yet-updated accept()ed sockets.
