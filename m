From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2] sctp: start t5 timer only when peer.rwnd is 0
 and local.state is SHUTDOWN_PENDING
Date: Thu, 27 Aug 2015 11:14:57 -0400
Message-ID: <55DF2971.5080009@redhat.com>
References: <e5d77a8d7c30ccbcc113506837ae7b8e90625046.1440329440.git.lucien.xin@gmail.com>	<55DB5ED2.1050702@redhat.com>	<20150824183146.GB1873@localhost.localdomain>	<55DB644B.1090305@redhat.com>	<CADvbK_cZhT3crJhP-5HQVpm=iAYTCDkiBNnDNCibvfOvEyzN7w@mail.gmail.com>	<55DF10E6.3010007@redhat.com> <CADvbK_eZfJpQtvM_zTyS=3yTuCkdK0RM-zbMbFvUx5L-U9u5jQ@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	network dev <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@infradead.org>, davem <davem@davemloft.net>
To: lucien xin <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746AbbH0PO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 11:14:58 -0400
In-Reply-To: <CADvbK_eZfJpQtvM_zTyS=3yTuCkdK0RM-zbMbFvUx5L-U9u5jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2015 10:49 AM, lucien xin wrote:
>>
>> So one potential way is to have peer.rwnd and peer.a_rwnd, where peer.a_rwnd is
>> the window advertised by peer and peer.rwnd and our estimation based on peer.a_rwnd.
>> This way we will always know where we stand.
>>
>> Although I am not sure yet if we want to grow the peer structure any more.
>>
>> Another way is to have an estimate or 0-window probe bit/flags one the send side
>> and set it when we do 0-window probe.  This way we'd know that when 0-window probe
>> bit is set, peer returned 0 window.
>>
> I think updating 0-window may happen in sctp_process_init() and
> sctp_outq_sack(),
> I don't think 0-window can be probed, cause unreachable and closing
> window both has
> no reply from peer. but we can update the 0-window bit in those two
> functions. I just do
> not know where there is a available bit we can use if won't change the
> peer structure.

You can ignore INIT as the window will never be 0 (not allowed).

The updates could happen at the end of sctp_outq_sack().   There some spare
bits in peer if you want to go that way.

-vlad


> 
>> Just some thoughts.
>> -vlad
