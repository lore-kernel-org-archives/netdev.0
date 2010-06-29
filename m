From: Yanko Kaneti <yaneti@declera.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Tue, 29 Jun 2010 15:53:51 +0300
Message-ID: <1277816031.3640.14.camel@d2>
References: <20100610124047.GA16658@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S.Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S.Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Matt Mackall <mpm@selenic.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from indigo.declera.com ([212.116.131.21]:57488 "HELO
	indigo.declera.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754652Ab0F2NAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 09:00:46 -0400
In-Reply-To: <20100610124047.GA16658@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-10 at 22:40 +1000, Herbert Xu wrote:
> Hi:
> 
> Qianfeng Zhang reported that he was seeing crashes with the
> attached backtrace.
> 
> I tracked this down to the recently added netpoll support in
> the bridge device.  It's a classic use-after-free problem.
> 
> Trying to solve it brought out a host of other issues, some of
> which existed prior to the new bridge code.  The following patches
> attempt to address some of these issues.
> 
> Warning, this is completely untested (apart from compiling with
> everything enabled) so please look but don't merge :)

FWIW 2.6.35-0.2.rc3.git0.fc14.x86_64 and later rawhide kernels are
causing quite reproducible __br_deliver crashes on routine f13
netinstalls in a kvm guest here.

To test I cherry picked this series +
netpoll-Use-correct-primitives-for-RCU-dereferencing and
net-fix-netpoll-Allow-netpoll_setup-cleanup-recursion from net-next on
top of 2.6.35-0.15.rc3.git3.fc14.x86_64 (which is todays linus tree) and
it seems to fix the crashes for me.

Perhaps the netpoll fixes should find their way to a rc before 2.6.35
goes golden.

Regards
Yanko

