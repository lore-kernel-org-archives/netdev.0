From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC][0/2] remove atm_find_ci(); convert vcc_sklist to hash
Date: Wed, 8 Oct 2003 06:58:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008065844.48fb53ae.davem@redhat.com>
References: <200310081246.h98CkPkT028970@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200310081246.h98CkPkT028970@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 08 Oct 2003 08:46:26 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> the following two patches (which should be applied to a current 2.6 tree)
> obseletes atm_find_ci() which races the vpi/vci allocation (since the 
> actual allocation is delayed until after the entering the drivers open()
> routine).  all drivers now use the built-in find_ci().  to address
> performance issues the second patch converts the vcc_sklist to a hash
> based on the lower 5 bits in the vci.

These changes look fine, I'll add them to my tree.

> should this be tunable via config?

I don't think so, at least not now.  My advice is, keep it a constant
for now and if people run into perf problems and the hash table size
is determined to be the cause you can investigate how to choose
different hash table sizes.

This is exactly what we did with the TCP hashes.
