From: Andi Kleen <ak@suse.de>
Subject: Re: shutdown() and SHUT_RD on TCP sockets - broken?
Date: Wed, 9 Jul 2003 12:38:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709123810.2b94d753.ak@suse.de>
References: <27451.1057745479@www2.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mtk-lists@gmx.net
In-Reply-To: <27451.1057745479@www2.gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 9 Jul 2003 12:11:19 +0200 (MEST)
mtk-lists@gmx.net wrote:

.
> 
> > From viewpoint of TCP the behaviour described in Stevens' book
> > is highly unnatural. SHUT_RD on TCP does not make any sense.
> 
> A while back I had some communication with Andi Kleen on this point,
> and he suggested that the TCP could send an RST in this case, much 

Linux sends an RST when data arrives that the  user cannot read anymore 
because the receiving socket is already closed. It would make sense to extend
this behaviour to SHUT_RD. But there is no natural place to implement it
outside the fast path, and it's so obscure that it is not worth slowing
common cases down.

-Andi
