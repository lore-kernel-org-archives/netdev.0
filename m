From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Mon, 9 Oct 2017 19:15:33 +0200
Message-ID: <20171009171533.y5x7y55cksga2e7q@alphalink.fr>
References: <20171001102110.24184f1b@xeon-e3>
 <CAEwTi7QkF73cc1hShzOoM9bzb5mBzyFW8t68OCn+XECrJ9d61Q@mail.gmail.com>
 <1506952566.8061.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA++DawY6CPh5S8A7pPE+-nwwGxJ4=pKL_MkXT_Q5TZb8xFnCjA@mail.gmail.com>
 <CAEwTi7S3-B81bNxyWq8j4hUpXyqNnTADReYoKoGF-V4wC5OBkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SviMik <svimik@gmail.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:54258 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754151AbdJIRPn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:15:43 -0400
Content-Disposition: inline
In-Reply-To: <CAEwTi7S3-B81bNxyWq8j4hUpXyqNnTADReYoKoGF-V4wC5OBkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 08:27:32AM +0100, James Chapman wrote:
> On 2 October 2017 at 19:35, SviMik <svimik@gmail.com> wrote:
> > Hi, James!
> >
> > No, I'm suffering from kernel panics since I started using 4.x
> > kernels.
> It's interesting that you are seeing l2tp issues since switching to
> 4.x kernels. Are you able to try earlier kernels to find the latest
> version that works? I'm curious whether things broke at v3.15.
> 
> > See my current collection:
> > http://svimik.com/hdmmsk1kp1.png
> This one is another crash implicating l2tp socket shutdown, this time
> when the session pppol2tp socket is closed. Unfortunately the
> screenshot doesn't show the full oops text. I'll investigate this one
> too if you can get a full oops capture.
> 
For this one too, it looks like tunnel->sock is NULL. This time, it's
l2tp_session_free() that breaks, but the root issue is probably the
same: l2tp_tunnel_destruct() removes the tunnel concurrently, most
likely because the session was created on a closing tunnel (as was
suggested by James in another message). So here too, commit
f3c66d4e144a ("l2tp: prevent creation of sessions on terminated tunnels")
might be a good start.
