From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH net-next] ipvs: Avoid null-pointer deref in debug code
Date: Mon, 6 Oct 2014 08:56:40 -0700
Message-ID: <5432BBB8.9070206@fb.com>
References: <20141001174526.GA16206@mwanda> <1412556895-26891-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1410060940470.1738@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <horms@verge.net.au>, <dan.carpenter@oracle.com>,
	<lvs-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1410060940470.1738@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Julian,

On 10/05/2014 11:49 PM, Julian Anastasov wrote:
>
> 	You have to print the "daddr" variable as
> it was done before your patchset in the
> "Stopping traffic to %s address, dest: %p..." message
> because dest is not present in all cases, for example,
> for *bypass_xmit. Other places provide cp->daddr but
> for backup server some conns can live without cp->dest.

I've sent an updated patch that does this but I have some questions 
about other stuff that I find mildly confusing.  Specifically I didn't 
realize until looking at the call sites that !dest || daddr = 
dest->addr.ip (but maybe I'm wrong?)

If that's the case, why do we have the following line in __ip_vs_get_out_rt?

                 daddr = dest->addr.ip;

If that's /always/ true then we should add the following line or a 
comment to the same effect to clarify

	BUG_ON(dest && dest->addr.ip != daddr);

If that's not intended to always be true, then should the patch be the 
following?

	...%pI4", dest ? &dest->addr.ip : &daddr);

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
