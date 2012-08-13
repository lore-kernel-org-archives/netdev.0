From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [flame^Wreview] net: netprio_cgroup: rework update socket logic
Date: Mon, 13 Aug 2012 18:01:09 +0100
Message-ID: <20120813170109.GD23464@ZenIV.linux.org.uk>
References: <20120813015348.GZ23464@ZenIV.linux.org.uk>
 <502896C5.7080303@intel.com>
 <50289D7F.3070402@intel.com>
 <20120813121827.GB23464@ZenIV.linux.org.uk>
 <50293224.90803@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50293224.90803@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2012 at 09:58:12AM -0700, John Fastabend wrote:
> [...]
> 
> >HOWEVER, it still doesn't address more fundamental problem - somebody
> >creating a socket and passing it to you in SCM_RIGHTS datagram will
> >leave you with a socket you can do IO on, still tagged according to who
> >had created it.
> >
> >AFAICS, the whole point of that exercise was to allow third-party changing
> >the priorities of traffic on sockets already created by a process we now
> >move to a different cgroup.  Consider e.g. this:
> 
> Correct that is the point of the exercise.
> 
> To fix this specific case we could add a call to sock_update_netprioidx
> in scm_recv to set the sk_cgrp_prioidx value.

On every received descriptor, that is?  Eeek...
