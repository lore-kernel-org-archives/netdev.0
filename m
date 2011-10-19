From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Problem with ixgbe and TX locked on one cpu
Date: Wed, 19 Oct 2011 11:21:16 +0200
Message-ID: <4E9E968C.8020807@itcare.pl>
References: <4E988B1E.5000606@itcare.pl> <CAEuXFEy89F_=J_PJMSbQ1fDcOEkkpz2vucq3LcToi7rTcZHcDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010502050003020101070506"
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.iq.pl ([86.111.242.20]:44048 "EHLO smtp4.iq.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752948Ab1JSJVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 05:21:23 -0400
In-Reply-To: <CAEuXFEy89F_=J_PJMSbQ1fDcOEkkpz2vucq3LcToi7rTcZHcDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010502050003020101070506
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

W dniu 2011-10-18 20:57, Jesse Brandeburg pisze:
> CC: e1000-devel
>
> 2011/10/14 Pawe³ Staszewski<pstaszewski@itcare.pl>:
>> Hello
>>
>> I have weird problem with ixgbe and irq affinity / rx-tx queue assignment
> what application are you running, how are you using ixgbe? looks like
> a router.  is something changing the skb->rx_queue entry (like
> netfilter) or is there a layered device above ixgbe (bonding or ...) ?
Yes it is a router. - Quagga - BGP

There is few (10rules) iptables rules in INPUT - and nothing more

There are also namespaces running - and traffic is processed in namespaces.
no bonding

> why do your interrupts move after a long period? did you do it by
> hand? we recommend disabling irqbalance and hand tuning interrupts
> possibly with the set_irq_affinity.sh script.
Yes it was changed by hand to check why TX is processed on one interrupt.
Also now it is impossible to move this TX traffic to other interrupt.

All configuration for affinity is made by hand - no irqbalance running.

>> Statistics for my ethernet - ixgbe driver:
>> ethtool -S eth4
>> NIC statistics:
>>      rx_packets: 5815535848808
>>      tx_packets: 5811202378421
>>      rx_bytes: 4791001750842200
>>      tx_bytes: 4781190419358301
>>      rx_pkts_nic: 5815535848827
>>      tx_pkts_nic: 5811202378510
>>      rx_bytes_nic: 4837563124411799
>>      tx_bytes_nic: 4829987507084013
>>      lsc_int: 8
>>      tx_busy: 0
>>      non_eop_descs: 0
>>      rx_errors: 0
>>      tx_errors: 0
>>      rx_dropped: 0
>>      tx_dropped: 0
>>      multicast: 92494273
>>      broadcast: 268718206
>>      rx_no_buffer_count: 28829
>>      collisions: 0
>>      rx_over_errors: 0
>>      rx_crc_errors: 0
>>      rx_frame_errors: 0
>>      hw_rsc_aggregated: 0
>>      hw_rsc_flushed: 0
>>      fdir_match: 0
>>      fdir_miss: 0
>>      rx_fifo_errors: 0
>>      rx_missed_errors: 307051074
>>      tx_aborted_errors: 0
>>      tx_carrier_errors: 0
>>      tx_fifo_errors: 0
>>      tx_heartbeat_errors: 0
>>      tx_timeout_count: 0
>>      tx_restart_queue: 15926219
>>      rx_long_length_errors: 298
>>      rx_short_length_errors: 0
>>      tx_flow_control_xon: 0
>>      rx_flow_control_xon: 0
>>      tx_flow_control_xoff: 0
>>      rx_flow_control_xoff: 0
>>      rx_csum_offload_errors: 54173917
>>      alloc_rx_page_failed: 0
>>      alloc_rx_buff_failed: 0
>>      rx_no_dma_resources: 0
>>      tx_queue_0_packets: 68694825
>>      tx_queue_0_bytes: 9443750332
>>      tx_queue_1_packets: 8410961
>>      tx_queue_1_bytes: 2527763233
>>      tx_queue_2_packets: 14411252
>>      tx_queue_2_bytes: 1317132394
>>      tx_queue_3_packets: 15013508147
>>      tx_queue_3_bytes: 17364767277348
>>      tx_queue_4_packets: 62779891
>>      tx_queue_4_bytes: 63476596221
>>      tx_queue_5_packets: 11176001
>>      tx_queue_5_bytes: 2763600253
>>      tx_queue_6_packets: 4416357
>>      tx_queue_6_bytes: 611874984
>>      tx_queue_7_packets: 8933405
>>      tx_queue_7_bytes: 1837198524
>>      tx_queue_8_packets: 13292669
>>      tx_queue_8_bytes: 3241333510
>>      tx_queue_9_packets: 10747236
>>      tx_queue_9_bytes: 1805109931
>>      tx_queue_10_packets: 5795935258380
>>      tx_queue_10_bytes: 4763725304722245
>>      tx_queue_11_packets: 12073934
>>      tx_queue_11_bytes: 2982743045
>>      tx_queue_12_packets: 10523764
>>      tx_queue_12_bytes: 2637451199
>>      tx_queue_13_packets: 12480552
>>      tx_queue_13_bytes: 2434827407
>>      tx_queue_14_packets: 7401777
>>      tx_queue_14_bytes: 2413618099
>>      tx_queue_15_packets: 8269270
>>      tx_queue_15_bytes: 2854359576
>>      rx_queue_0_packets: 361373769507
>>      rx_queue_0_bytes: 298565751248279
>>      rx_queue_1_packets: 369901571908
>>      rx_queue_1_bytes: 303414679798160
>>      rx_queue_2_packets: 362508961738
>>      rx_queue_2_bytes: 299852439447157
>>      rx_queue_3_packets: 363449272013
>>      rx_queue_3_bytes: 299738390792515
>>      rx_queue_4_packets: 361876234461
>>      rx_queue_4_bytes: 297483366939732
>>      rx_queue_5_packets: 361402926316
>>      rx_queue_5_bytes: 297633876486533
>>      rx_queue_6_packets: 362261522767
>>      rx_queue_6_bytes: 298026696344647
>>      rx_queue_7_packets: 361248593301
>>      rx_queue_7_bytes: 296756459279986
>>      rx_queue_8_packets: 361654143416
>>      rx_queue_8_bytes: 298272433659520
>>      rx_queue_9_packets: 362781764710
>>      rx_queue_9_bytes: 298804803191595
>>      rx_queue_10_packets: 361386593064
>>      rx_queue_10_bytes: 297434987797644
>>      rx_queue_11_packets: 369886597895
>>      rx_queue_11_bytes: 302353350171712
>>      rx_queue_12_packets: 361582732276
>>      rx_queue_12_bytes: 298670408005971
>>      rx_queue_13_packets: 365248093536
>>      rx_queue_13_bytes: 302573023878287
>>      rx_queue_14_packets: 366571142073
>>      rx_queue_14_bytes: 302396739276514
>>      rx_queue_15_packets: 362401929830
>>      rx_queue_15_bytes: 299024344526029
>>
>> The problem is with queue 10
>>      tx_queue_10_packets: 5795935258380
>>      tx_queue_10_bytes: 4763725304722245
>>
>> as you can see most of the queue processing is used in queue 10
>> Average difference is 1,854271229903958e-6  - compared to other queues
>>
>> and the problem is that almost all TX packet processing is on one CPU
>> cat /proc/interrupts - in attached file
>>
>> Is this driver or kernel problem ?
>>
>> Kernel is: 2.6.38.2
>>
>> ixgbe driver is:
>> ethtool -i eth4
>> driver: ixgbe
>> version: 3.2.9-k2
>> firmware-version: 1.12-2
>> bus-info: 0000:04:00.0
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


-- 


--------------010502050003020101070506
Content-Type: text/x-vcard; charset=utf-8;
 name="pstaszewski.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="pstaszewski.vcf"

begin:vcard
fn;quoted-printable:Pawe=C5=82 Staszewski
n;quoted-printable:Staszewski;Pawe=C5=82
org:ITCare
adr;quoted-printable;quoted-printable;dom:;;Sikorskiego 22;Libi=C4=85=C5=BC;Ma=C5=82opolskie;32-590
title:IT Manager
tel;work:+48 32 7203681
tel;fax:+48 32 7203682
tel;cell:+48 0 609911040
url:www.itcare.pl
version:2.1
end:vcard


--------------010502050003020101070506--
