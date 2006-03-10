From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: TSO and IPoIB performance degradation
Date: Fri, 10 Mar 2006 02:38:11 +0200
Message-ID: <20060310003811.GA23187@mellanox.co.il>
References: <adaacc1raz9.fsf@cisco.com> <20060307.172336.107863253.davem@davemloft.net> <20060308125311.GE17618@mellanox.co.il> <20060309.154819.104282952.davem@davemloft.net> <20060310001031.GA19040@mellanox.co.il>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	shemminger@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932617AbWCJAi5@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060310001031.GA19040@mellanox.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. Michael S. Tsirkin <mst@mellanox.co.il>:
> Or does __tcp_ack_snd_check delay until we have at least two full sized
> segments?

What I'm trying to say, since RFC 2525, 2.13 talks about
"every second full-sized segment", so following the code from
__tcp_ack_snd_check, why does it do

	    /* More than one full frame received... */
	if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss

rather than

	    /* At least two full frames received... */
	if (((tp->rcv_nxt - tp->rcv_wup) >= 2 * inet_csk(sk)->icsk_ack.rcv_mss

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
