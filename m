From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Thu, 7 Apr 2005 17:26:41 -0300
Message-ID: <20050407172641.K11215@almesberger.net>
References: <20050407164146.GA6479@ev-en.org> <20050407101653.2cc68db1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baruch Even <baruch@ev-en.org>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050407101653.2cc68db1@dxpl.pdx.osdl.net>; from shemminger@osdl.org on Thu, Apr 07, 2005 at 10:16:53AM -0700
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I think this is a real problem, and was observed by Werner with umlsim.
> Don't know when it got introduced because it appears to pre-date the
> '04 work in adding Westwood, BIC, Vegas. Perhaps Alexey can shed some
> light on this.

If this is still the old cwnd quartering bug, then it's very very
old. Cheng Jin and I spotted it at the end of 2002 in 2.4.18, but
didn't look at earlier versions. (Later, I used this problem to
demonstrate how to fix bugs on the fly in umlsim.)

You can find the whole discussion in the following two threads:
http://thread.gmane.org/gmane.linux.network/2094
http://thread.gmane.org/gmane.linux.network/2223

Note that the fix isn't trivial (or, at least, it wasn't when we
looked at it), because just eliminating the /2 would make us too
aggressive in another, even weirder case, as I've described in
http://article.gmane.org/gmane.linux.network/2221
(which I admit to be somewhat daunting reading).

Recently, I noticed that my umlsim-based "hotfix" wouldn't improve
things in recent kernels anymore. I thought "cool, someone finally
sat down and fixed it", but perhaps that was premature.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
