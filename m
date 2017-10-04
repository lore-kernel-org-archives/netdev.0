From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/1] XDP Program for Ip forward
Date: Wed, 4 Oct 2017 17:07:55 +0200
Message-ID: <20171004170755.4b1d8de4@redhat.com>
References: <1507016225-319-1-git-send-email-Christina.Jacob@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: cjacob <Christina.Jacob@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507016225-319-1-git-send-email-Christina.Jacob@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


First of all thank you for working on this.

On Tue,  3 Oct 2017 13:07:04 +0530 cjacob <Christina.Jacob@cavium.com> wrote:

> 	Usage: ./xdp3 [-S] <ifindex1...ifindexn> 
> 
> 	-S to choose generic xdp implementation 
> 	  [Default is driver xdp implementation]
> 	ifindex - the index of the interface to which 
> 	the xdp program has to be attached.
> 	in 4.14-rc3 kernel.

I would prefer if we can name the program something more descriptive
than "xdp3".  What about "xdp_redirect_router" or "xdp_router_ipv4" ?

I would also appreciate if we can stop using ifindex'es, and instead
use normal device ifname's.  And simply do the lookup to the ifindex in
the program via if_nametoindex(ifname), see how in [1] and [2].

When adding more ifname's you can just use the same trick as with
multiple --cpu options like [1] and [2].

[1] http://lkml.kernel.org/r/150711864538.9499.11712573036995600273.stgit@firesoul
[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_redirect_cpu_user.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
