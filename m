From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: kernel BUG at page_alloc.c:98 -- compiling with distcc
Date: Fri, 30 Apr 2004 02:15:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040430001521.GV29954@dualathlon.random>
References: <382320000.1082759593@taltos.ny.ficc.gs.com> <16527.4259.174536.629347@segfault.boston.redhat.com> <20040429210951.GB20453@logos.cnet> <20040429142807.1fa4c5ea.akpm@osdl.org> <20040429224936.GT29954@dualathlon.random> <20040429162632.689fa7fe.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo.tosatti@cyclades.com, jmoyer@redhat.com, carson@taltos.org,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040429162632.689fa7fe.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 29, 2004 at 04:26:32PM -0700, Andrew Morton wrote:
> The only application which we know will exercise that code is the distcc
> server.  Making that little change while testing the patch will increase
> the chance of shaking out any problems.

if you're scared it has bugs I think it'd be more useful to change it to
"|| 1" and run it under some stress test, and then remove the "|| 1".
the aio code in unmap_kvec is also a big user of that.  a schedule every
40M of ram freed isn't too nice to my eyes (but I doubt it can be
measured).
