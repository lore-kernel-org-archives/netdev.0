From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver and samba
Date: Sat, 15 Sep 2007 12:07:06 -0700
Message-ID: <46EC2D5A.7080504@intel.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
 <46EAC25B.2060404@intel.com>
 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
 <46EAF644.1040006@intel.com> <46EC1A00.2000304@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>, L F <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:41464 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbXIOTH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 15:07:56 -0400
Received: from ahkok-mobl.jf.intel.com ([71.182.85.189])
 by vms042.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JOF00L0QBS9KMC3@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Sat, 15 Sep 2007 14:07:22 -0500 (CDT)
In-reply-to: <46EC1A00.2000304@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> Kok, Auke wrote:
>> L F wrote:
>>> On 9/14/07, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>>>> this slowness might have been masking the issue
>>> That is possible. However, it worked for upwards of twelve months
>>> without an error.
>>>
>>>> I have not yet seen other reports of this issue, and it would be 
>>>> interesting to
>>>> see if the stack or driver is seeing errors. Please post `ethtool -S 
>>>> eth0` after
>>>> the samba connection resets or fails.
>>> If you look for it on the Realtek cards, there had been sporadic
>>> issues up to late 2005. The solution posted universally was 'change
>>> card'.
>>>
>>> I include the content of ethtool -S as requested:
>>> beehive:~# ethtool -S eth4
>>> NIC statistics:
>>>      rx_packets: 43538709
>>>      tx_packets: 68726231
>>>      rx_bytes: 34124849453
>>>      tx_bytes: 74817483835
>>>      rx_broadcast: 20891
>>>      tx_broadcast: 8941
>>>      rx_multicast: 459
>>>      tx_multicast: 0
>>>      rx_errors: 0
>>>      tx_errors: 0
>>>      tx_dropped: 0
>>>      multicast: 459
>>>      collisions: 0
>>>      rx_length_errors: 0
>>>      rx_over_errors: 0
>>>      rx_crc_errors: 0
>>>      rx_frame_errors: 0
>>>      rx_no_buffer_count: 0
>>>      rx_missed_errors: 0
>>>      tx_aborted_errors: 0
>>>      tx_carrier_errors: 0
>>>      tx_fifo_errors: 0
>>>      tx_heartbeat_errors: 0
>>>      tx_window_errors: 0
>>>      tx_abort_late_coll: 0
>>>      tx_deferred_ok: 486

this one I wonder about, and might cause delays, I'll have to look up what it 
exactly could implicate though.

>>>      tx_single_coll_ok: 0
>>>      tx_multi_coll_ok: 0
>>>      tx_timeout_count: 0
>>>      tx_restart_queue: 0
>>>      rx_long_length_errors: 0
>>>      rx_short_length_errors: 0
>>>      rx_align_errors: 0
>>>      tx_tcp_seg_good: 0
>>>      tx_tcp_seg_failed: 0
>>>      rx_flow_control_xon: 488
>>>      rx_flow_control_xoff: 488
>>>      tx_flow_control_xon: 0
>>>      tx_flow_control_xoff: 0
>>>      rx_long_byte_count: 34124849453
> 
> Are these long frames expected in your network? What is the MTU of the 
> transmitting clients? Perhaps this might explain why reads work (because 
> data is coming from the Linux box so the packets have smaller MTU) while 
> writes cause delays or packet loss because the clients are sending long 
> frames which are getting fragmented?

those are not "long frames" but the number of bytes the hardware counted in its 
"long" data type based byte counter.

Auke
