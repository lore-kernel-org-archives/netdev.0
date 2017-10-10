From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2] XDP Program for Ip forward
Date: Tue, 10 Oct 2017 15:12:31 +0200
Message-ID: <20171010151231.69fde82f@redhat.com>
References: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, Sunil.Goutham@cavium.com,
        daniel@iogearbox.net, dsahern@gmail.com,
        Christina Jacob <Christina.Jacob@cavium.com>, brouer@redhat.com
To: Christina Jacob <christina.jacob.koikara@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 10 Oct 2017 12:58:51 +0530 Christina Jacob <christina.jacob.koikara@gmail.com> wrote:

> The patch below implements port to port forwarding through route table and arp
> table lookup for ipv4 packets using bpf_redirect helper function and lpm_trie
> map.  This has an improved performance over the normal kernel stack ip forward.
> 
> Implementation details.
> -----------------------
[...]
> 
> In the xdp3_user.c,
> 
[...]
> 
> In the xdp3_kern.c,

You forgot to update the program name in the cover letter.

> The array map for the 32 bit mask entries checked to see if there is a key that
> exactly matches with the destination ip. If it has a non zero destination mac
> entry then the xdp data is updated accordingly Otherwise a proper route and 
> arp table lookup is done using the lpm_trie and the arp table array map.
> 	
> 	Usage: as ./xdp3 -S <ifindex1...ifindexn> (-S for
                    ^^^^^
The executable name also changed.

> 	generic xdp implementation ifindex- the index of the interface to which
> 	the xdp program has to be attached.) in 4.14-rc3 kernel.
> 
> Changes from v1 to v2
> ---------------------
>  
> * As suggested by Jesper Dangaard Brouer
> 	1. Changed the program name to  list xdp_router_ipv4

Thanks

> 	2. Changed the commandline arguments from ifindex list to interface name
> 		Usage : ./xdp_router_ipv4 [-S] <interface name list>
> 		-S for generic xdp implementation
> 		-interface name list is the list of interfaces to which
> 		the xdp program should attach to

Okay, you choose a slightly different way of implementing this, but it
shouldn't matter.

I'll try to test/benchmark your program...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
