From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: 100% CPU load when generating traffic to destination network that
 nexthop is not reachable
Date: Tue, 15 Aug 2017 19:42:37 +0200
Message-ID: <baa1807d-cc00-0182-4b34-4d986d62ebcb@itcare.pl>
References: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>
 <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.iq.pl ([86.111.242.224]:35918 "EHLO smtp19.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751580AbdHORnn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 13:43:43 -0400
In-Reply-To: <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


# To display the perf.data header info, please use 
--header/--header-only options.
#
#
# Total Lost Samples: 0
#
# Samples: 2M of event 'cycles'
# Event count (approx.): 1585571545969
#
# Children      Self  Command         Shared Object         Symbol
# ........  ........  ..............  .................... 
..............................................
#
      1.82%     0.00%  ksoftirqd/43    [kernel.vmlinux]      [k] 
__softirqentry_text_start
             |
              --1.82%--__softirqentry_text_start
                        |
                         --1.82%--net_rx_action
                                   |
                                    --1.82%--mlx5e_napi_poll
                                              |
--1.81%--mlx5e_poll_rx_cq
                                                         |
--1.81%--mlx5e_handle_rx_cqe
                                                                    |
--1.79%--napi_gro_receive
|
--1.78%--netif_receive_skb_internal
|
--1.78%--__netif_receive_skb
|
--1.78%--__netif_receive_skb_core
|
--1.78%--ip_rcv
|
--1.78%--ip_rcv_finish
|
--1.76%--ip_forward
|
--1.76%--ip_forward_finish
|
--1.76%--ip_output
|
--1.76%--ip_finish_output
|
--1.76%--ip_finish_output2
|
--1.73%--neigh_resolve_output
|
--1.73%--neigh_event_send
|
--1.73%--__neigh_event_send
|
--1.70%--_raw_write_lock_bh
queued_write_lock
queued_write_lock_slowpath
|
--1.67%--queued_spin_lock_slowpath



W dniu 2017-08-15 o 18:57, Eric Dumazet pisze:
> On Tue, 2017-08-15 at 18:30 +0200, Paweł Staszewski wrote:
>> Hi
>>
>>
>> Doing some tests i discovered that when traffic is send by pktgen to
>> forwarding host where nexthop for destination network on forwarding
>> router is not reachable i have 100% cpu on all cores and perf top show
>> mostly:
>>
>>       77.19%  [kernel]            [k] queued_spin_lock_slowpath
>>       10.20%  [kernel]            [k] acpi_processor_ffh_cstate_enter
>>        1.41%  [kernel]            [k] queued_write_lock_slowpath
>>
> To the rescue (for us to help)
>
> perf record -a -g sleep 10
>
> perf report --stdio
>
>
>
>
