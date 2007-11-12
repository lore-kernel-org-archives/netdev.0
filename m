From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] [PATCH] Fix memory leak in discard case of
 sctp_sf_abort_violation()
Date: Mon, 12 Nov 2007 10:14:46 -0500
Message-ID: <47386DE6.4020207@hp.com>
References: <200711112357.49577.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lksctp developers <lksctp-developers@lists.sourceforge.net>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756863AbXKLPPH@vger.kernel.org>
In-Reply-To: <200711112357.49577.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl wrote:
> From: Jesper Juhl <jesper.juhl@gmail.com>
> 
> In net/sctp/sm_statefuns.c::sctp_sf_abort_violation() we may leak 
> the storage allocated for 'abort' by returning from the function 
> without using or freeing it. This happens in case 
> "sctp_auth_recv_cid(SCTP_CID_ABORT, asoc)" is true and we jump to 
> the 'discard' label.
> Spotted by the Coverity checker.
> 
> The simple fix is to simply move the creation of the "abort chunk" 
> to after the possible jump to the 'discard' label. This way we don't   
> even have to allocate the memory at all in the problem case.
> 
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

Thanks.  I've applied this to my tree.

-vlad
