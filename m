From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Sat, 8 Jul 2017 21:06:17 +0200
Message-ID: <20170708210617.249059b9@redhat.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <595FC974.9030807@gmail.com>
        <20170708.104618.2149883426031901592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com,
        brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44088 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753061AbdGHTG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Jul 2017 15:06:28 -0400
In-Reply-To: <20170708.104618.2149883426031901592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 08 Jul 2017 10:46:18 +0100 (WEST)
David Miller <davem@davemloft.net> wrote:

> From: John Fastabend <john.fastabend@gmail.com>
> Date: Fri, 07 Jul 2017 10:48:36 -0700
> 
> > On 07/07/2017 10:34 AM, John Fastabend wrote:  
> >> This series adds two new XDP helper routines bpf_redirect() and
> >> bpf_redirect_map(). The first variant bpf_redirect() is meant
> >> to be used the same way it is currently being used by the cls_bpf
> >> classifier. An xdp packet will be redirected immediately when this
> >> is called.  
> > 
> > Also other than the typo in the title there ;) I'm going to CC
> > the driver maintainers working on XDP (makes for a long CC list but)
> > because we would want to try and get support in as many as possible in
> > the next merge window.
> > 
> > For this rev I just implemented on ixgbe because I wrote the
> > original XDP support there. I'll volunteer to do virtio as well.  
> 
> I went over this series a few times and it looks great to me.
> You didn't even give me some coding style issues to pick on :-)

We (Daniel, Andy and I) have been reviewing and improving on this
patchset the last couple of weeks ;-).  We had some stability issues,
which is why it wasn't published earlier. My plan is to test this
latest patchset again, Monday and Tuesday. I'll try to assess stability
and provide some performance numbers.

I've complained/warned about the danger of redirecting with XDP,
without providing (1) a way to debug/see XDP redirects, (2) a way
interfaces opt-in they can be redirected. (1) is solved by patch-07/12
via a tracepoint. (2) is currently done by only forwarding to
interfaces with an XDP program loaded itself, this also comes from a
practical need for NIC drivers to allocate XDP-TX HW queues.

I'm not satisfied with the (UAPI) name for the new map
"BPF_MAP_TYPE_DEVMAP" and the filename this is placed in
"kernel/bpf/devmap.c", as we want to take advantage of compiler
inlining for the next redirect map types.  (1) because the name doesn't
tell the user that this map is connected to the redirect_map call.
(2) we want to introduce other kinds of redirect maps (like redirect to
CPUs and sockets), and it would be good if they shared a common "text"
string.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
