From: "David S. Miller" <davem@davemloft.net>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Tue, 5 Apr 2005 12:34:38 -0700
Message-ID: <20050405123438.28f02423.davem@davemloft.net>
References: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@lameter.com>
In-Reply-To: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Apr 2005 11:55:45 -0700 (PDT)
Christoph Lameter <christoph@lameter.com> wrote:

> Is the atomic_dec_and_test in dst_destroy just there to join two atomic
> operations into one without being necessary for the correctness of freeing
> dsts?

Otimizing big SGI NUM systems again, are you?  :-)

atomic_dec() has no memory ordering guarentees, only the atomic
routines returning values do the proper SMP memory barriers.
So, based upon this alone I don't think your change is valid.

I've even documented this fully, see Documentation/atomic_ops.txt
