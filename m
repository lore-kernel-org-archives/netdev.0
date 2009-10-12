From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: Use the instance of
	net_device_stats from net_device.
Date: Mon, 12 Oct 2009 17:40:57 +0530
Message-ID: <20091012121055.GA10799@serverengines.com>
References: <20091007124339.GA30083@serverengines.com> <EA929A9653AAE14F841771FB1DE5A1365F98A89A0B@rrsmsx501.amr.corp.intel.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:64391 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755732AbZJLMLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 08:11:42 -0400
Received: by pzk26 with SMTP id 26so8027953pzk.4
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 05:11:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F98A89A0B@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/09 15:55 -0600, Tantilov, Emil S wrote:
> Ajit Khaparde wrote:
> > Since net_device has an instance of net_device_stats,
> > we can remove the instance of this from the private adapter structure.
> > 
> > Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> 
> I am seeing an issues with these patches where some counters are messed up:
> 
Thanks for testing the changes.
There was an error in the way I was trying to offset for the netdev stats.
I have a fix for it now.  I would like to know if you would prefer an
incremental patch or a patch with the previous changes too. 
I will mail the patches accordingly.  Sorry for the delay in sending this out.

-Ajit
> --- ixgbe ---
> 
> NIC statistics:
>      rx_packets: 18446612147046614784
>      tx_packets: 18446612147046614784
>      rx_bytes: 18446744072099799523
>      tx_bytes: 18446744072099857640
>      rx_pkts_nic: 12
>      tx_pkts_nic: 19
>      rx_bytes_nic: 1148
>      tx_bytes_nic: 1762
>      lsc_int: 4
>      tx_busy: 0
>      non_eop_descs: 0
>      rx_errors: 0
>      tx_errors: 18446744072099850983
>      rx_dropped: 18446612140591825160
>      tx_dropped: 18446612140591825424
>      multicast: 18446612140591825952
>      broadcast: 0
>      rx_no_buffer_count: 0
>      collisions: 18446612140591825688
>      rx_over_errors: 18446612140591827008
>      rx_crc_errors: 18446612140591827272
>      rx_frame_errors: 18446612140591827536
>      hw_rsc_count: 0
>      fdir_match: 0
>      fdir_miss: 10
>      rx_fifo_errors: 18446612140591827800
>      rx_missed_errors: 18446612140591828064
>      tx_aborted_errors: 18446612140591828328
>      tx_carrier_errors: 18446612140591828592
>      tx_fifo_errors: 18446612140591828856
>      tx_heartbeat_errors: 18446612140591829120
> 	...
> 
> --- igb ---
> NIC statistics:
>      rx_packets: 0
>      tx_packets: 0
>      rx_bytes: 0
>      tx_bytes: 0
>      rx_broadcast: 0
>      tx_broadcast: 0
>      rx_multicast: 0
>      tx_multicast: 0
>      rx_errors: 0
>      tx_errors: 0
>      tx_dropped: 18446744072099036908
>      multicast: 0
>      collisions: 0
>      rx_length_errors: 0
>      rx_over_errors: 65535
>      rx_crc_errors: 0
>      rx_frame_errors: 0
>      rx_no_buffer_count: 0
>      rx_queue_drop_packet_count: 0
>      rx_missed_errors: 0
>      tx_aborted_errors: 0
>      tx_carrier_errors: 0
>      tx_fifo_errors: 0
>      tx_heartbeat_errors: 18446612146842011544
> 	...
> 
> --- e1000 ---
> NIC statistics:
>      rx_packets: 0
>      tx_packets: 0
>      rx_bytes: 0
>      tx_bytes: 0
>      rx_broadcast: 0
>      tx_broadcast: 0
>      rx_multicast: 0
>      tx_multicast: 0
>      rx_errors: 0
>      tx_errors: 0
>      tx_dropped: 18446744072099165544
>      multicast: 0
>      collisions: 0
>      rx_length_errors: 0
>      rx_over_errors: 0
>      rx_crc_errors: 0
>      rx_frame_errors: 18446744072099094496
>      rx_no_buffer_count: 0
>      rx_missed_errors: 0
>      tx_aborted_errors: 0
>      tx_carrier_errors: 0
>      tx_fifo_errors: 0
>      tx_heartbeat_errors: 4294967295
> 	...
> 
>  --- e1000e ---
> NIC statistics:
>      rx_packets: 0
>      tx_packets: 7
>      rx_bytes: 0
>      tx_bytes: 614
>      rx_broadcast: 0
>      tx_broadcast: 0
>      rx_multicast: 0
>      tx_multicast: 7
>      rx_errors: 0
>      tx_errors: 0
>      tx_dropped: 18446744072099315636
> 
> Thanks,
> Emil--
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
