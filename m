From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: linux-3.14-rc1 & PACKET_QDISC_BYPASS : slow_path warning
Date: Tue, 04 Feb 2014 13:56:01 +0100
Message-ID: <52F0E361.9000304@redhat.com>
References: <52F01C97.20001@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Jesper Dangaard Brouer <jbrouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Mathias Kretschmer <mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52F01C97.20001-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Mathias, [cc'ing Felix]

On 02/03/2014 11:47 PM, Mathias Kretschmer wrote:
> Hi Daniel,
>
> we are developing a wired/wireless MPLS switch. Currently the data plane runs in user space using PF_PACKET sockets via RX_RING/TX_RING.
>
> We had hoped to test the PACKET_QDISC_BYPASS option since this seems to be the proper optimization for our purposes.
>
> Unfortunately, we're seeing a 'slow path' warning for every packet that is being sent out. With PACKET_QDISC_BYPASS disabled, no warnings are dumped. Hardware is an older AMD Geode LX embedded board (ALiX).
>
> BTW, this happens while sending via a wireless (802.11) adhoc interface. Hence, it might be an interaction with the ieee80211 sub system.

Hm, so the WARN_ON() is triggered inside ath9k driver in relation to 802.11 QoS,
and came in from commit 066dae93bdf ("ath9k: rework tx queue selection and fix
queue stopping/waking"). We did the stress testing of that option for PF_PACKET
on 10Gbit/s NICs. Seems to me you might be running into the same issue when using
pktgen as it randomly or per round-robin selects tx queues as well? Not entirely
sure how necessary this WARN_ON() is though, Felix? I think QDISC_BYPASS might not
be the best option in your case, perhaps you will run into increased power usage
in your NIC as a side-effect?

Cheers,

Daniel
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
