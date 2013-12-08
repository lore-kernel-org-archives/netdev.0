From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Sun, 8 Dec 2013 14:43:52 +0200
Message-ID: <20131208124352.GA7935@zed.ravello.local>
References: <alpine.LFD.2.03.1312031310140.23893@intel.com>
 <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
 <alpine.LFD.2.03.1312031500020.570@intel.com>
 <CAJZOPZLT_3msfz_XY45GOBMWK_y8WEYBTq3rGRUijpYyXE1ddg@mail.gmail.com>
 <alpine.LFD.2.03.1312031626400.7539@intel.com>
 <CAJZOPZJKsrj2+SQJsgq-w7BrNwDR0OsYWiF+1CcRQ3-KhejZhQ@mail.gmail.com>
 <alpine.LFD.2.03.1312040113290.14367@intel.com>
 <CAJZOPZJVBpqm-OduV4K2YwbXESP7awhsk0HbjuHazAiQJZTLWQ@mail.gmail.com>
 <52A197DF.5010806@mellanox.com>
 <CAJZOPZJ20j9KaaMkyQmhYDkimzAM5tvxJLDzmpiAcvG0Bcky6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:54224 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617Ab3LHMn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 07:43:58 -0500
Received: by mail-ea0-f172.google.com with SMTP id q10so1066479ead.17
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 04:43:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJZOPZJ20j9KaaMkyQmhYDkimzAM5tvxJLDzmpiAcvG0Bcky6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 06, 2013 at 11:30:37AM +0200, Or Gerlitz wrote:
> > On 04/12/2013 11:41, Or Gerlitz wrote:
> 
> BTW guys, I saw the issues with both bridge/openvswitch configuration
> - seems that we might have here somehow large breakage of the system
> w.r.t vxlan traffic for rates that go over few Gbs -- so would love to
> get feedback of any kind from the people that were involved with vxlan
> over the last months/year.

I've seen similar problems with vxlan traffic. In our scenario I had two VMs
running on the same host and both VMs having the { veth --> bridge -->
vlxan --> IP stack --> NIC } chain. 
Running iperf on veth showed rate ~6 times slower than direct NIC <-> NIC.
With a hack that forces large gso_size in vxlan's handle_offloads, I've
got veth performing only slightly slower than NICs ...
The explanation I thought of is that performing the split of the packet
as late as possible reduces processing overhead and allows more data to
be processed.

My $0.02

> 
> Or.
> 
--
Sincerely yours,
Mike.
