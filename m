From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Fri, 17 Dec 2010 14:12:56 +0800
Message-ID: <AANLkTi=VAi5p85aR4U3zu4i0qB5=E=5x766MUaQS-cu7@mail.gmail.com>
References: <cover.1292405004.git.fenghua.yu@intel.com>
	<46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
	<1292446118.2603.11.camel@edumazet-laptop>
	<20101216011425.GA17446@linux-os.sc.intel.com>
	<1292474660.2603.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fenghua Yu <fenghua.yu@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Tang, Xinan" <xinan.tang@intel.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292474660.2603.37.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 16, 2010 at 12:44 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>
> We really need to be smarter than that, not adding raw API.
>
> Tom Herbert added RPS, RFS, XPS, in a way applications dont have to u=
se
> special API, just run normal code.
>
> Please understand that using 8 AF_PACKET sockets bound to a given dev=
ice
> is a total waste, because the way we loop on ptype_all before enterin=
g
> AF_PACKET code, and in 12% of the cases deliver the packet into a que=
ue,
> and 77.5% of the case reject the packet.
>
> This is absolutely not scalable to say... 64 queues.
>
> I do believe we can handle that using one AF_PACKET socket for the RX
> side, in order to not slow down the loop we have in
> __netif_receive_skb()
>
> list_for_each_entry_rcu(ptype, &ptype_all, list) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0deliver_skb(skb, pt_prev, orig_dev);
> }
>
> (Same problem with dev_queue_xmit_nit() by the way, even worse since =
we
> skb_clone() packet _before_ entering af_packet code)
>
> And we can change af_packet to split the load to N skb queues or N ri=
ng
> buffers, N not being necessarly number of NIC queues, but the number
> needed to handle the expected load.
>
> There is nothing preventing us changing af_packet/udp/tcp_listener to
> something more scalable in itself, using a set of receive queues, and
> NUMA friendly data set. We did multiqueue for a net_device like this,
> not adding N pseudo devices as we could have done.
>
Valuable comments. Thank you very much.

We'll cook a new version and resubmit it.


--=20
--Junchang
