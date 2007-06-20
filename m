From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: unexpected newReno behavior in 2.6.21.5
Date: Wed, 20 Jun 2007 14:50:04 -0400
Message-ID: <467976DC.3070209@redhat.com>
References: <8ea0411b0706201127t7133bd6cy2f8fcd547ec27361@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Sushant <sushantsharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756881AbXFTSuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 14:50:07 -0400
In-Reply-To: <8ea0411b0706201127t7133bd6cy2f8fcd547ec27361@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/20/2007 02:27 PM, Sushant wrote:

Sushant, you should be sending this kind of message to netdev.
[cc'd]

> Hi all,
> I am currently doing some analysis on the TCP newReno implementation
> in the Linux kernel and it looks like the sender behavior is not
> expected. Here is what I am observing.
> 
> Linux kernel: stable version 2.6.21.5
> 
> 1) _sometimes_, there is no fast recovery: i.e. after receiving three
> DUP acks, the sender is not transmitting new packets in response to
> the more DUP acks it is receiving after the first three. It does
> retransmit the lost packet after 3 DUP acks though.
> 
> 2) Delayed fast retransmit: _sometimes_, instead of retransmitting the
> lost packet after receiving 3 DUP acks, sender waits for large number
> (which is 127 most of the time) of DUP acks before retransmitting the
> lost packet. But, it keeps on transmitting a new packet for every one
> of 127 DUP acks it is receiving.
> 
> Has someone seen this behavior or is this behavior expected under some
> scenarios. I am using wireshark (previously ethereal) on sender to
> analyze all this. I can provide logs if needed or any other
> information that you might need. I have provided my sysctl output for
> TCP parameters at the end of my mail.
> 
> Please cc the replies to me as I am not subscribed to the list.
> 
> TIA
> -Sushant
> 
> 
> #  /sbin/sysctl -a  | grep tcp
> net.ipv4.tcp_timestamps = 1
> net.ipv4.tcp_window_scaling = 1
> net.ipv4.tcp_sack = 0
> net.ipv4.tcp_retrans_collapse = 1
> net.ipv4.tcp_syn_retries = 5
> net.ipv4.tcp_synack_retries = 5
> net.ipv4.tcp_max_orphans = 32768
> net.ipv4.tcp_max_tw_buckets = 180000
> net.ipv4.tcp_keepalive_time = 7200
> net.ipv4.tcp_keepalive_probes = 9
> net.ipv4.tcp_keepalive_intvl = 75
> net.ipv4.tcp_retries1 = 3
> net.ipv4.tcp_retries2 = 15
> net.ipv4.tcp_fin_timeout = 60
> net.ipv4.tcp_syncookies = 1
> net.ipv4.tcp_tw_recycle = 0
> net.ipv4.tcp_abort_on_overflow = 0
> net.ipv4.tcp_stdurg = 0
> net.ipv4.tcp_rfc1337 = 0
> net.ipv4.tcp_max_syn_backlog = 1024
> net.ipv4.tcp_orphan_retries = 0
> net.ipv4.tcp_fack = 1
> net.ipv4.tcp_reordering = 3
> net.ipv4.tcp_ecn = 0
> net.ipv4.tcp_dsack = 1
> net.ipv4.tcp_mem = 1048576      1048576 1048576
> net.ipv4.tcp_wmem = 1048576     1048576 1048576
> net.ipv4.tcp_rmem = 1048576     1048576 1048576
> net.ipv4.tcp_app_win = 31
> net.ipv4.tcp_adv_win_scale = 3
> net.ipv4.tcp_tw_reuse = 0
> net.ipv4.tcp_frto = 0
> net.ipv4.tcp_low_latency = 0
> net.ipv4.tcp_no_metrics_save = 1
> net.ipv4.tcp_moderate_rcvbuf = 1
> net.ipv4.tcp_tso_win_divisor = 3
> net.ipv4.tcp_congestion_control = reno
> net.ipv4.tcp_abc = 0
> net.ipv4.tcp_mtu_probing = 0
> net.ipv4.tcp_base_mss = 512
> net.ipv4.tcp_workaround_signed_windows = 0
> net.ipv4.tcp_slow_start_after_idle = 1
> net.ipv4.tcp_available_congestion_control = reno bic cubic
> net.ipv4.tcp_allowed_congestion_control = reno
> sunrpc.tcp_slot_table_entries = 16
