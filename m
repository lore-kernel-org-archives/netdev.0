From: Frans Klaver <fransklaver@gmail.com>
Subject: Re: [RFC PATCH v2] packet: remove handling of tx_ring
Date: Mon, 22 Jun 2015 09:00:50 +0200
Message-ID: <CAH6sp9P2UejTaX=3aw4boKwtxMuypWxM2W0k=9xP7q=YArrmbg@mail.gmail.com>
References: <1504484104.41691434955982414.JavaMail.weblogic@ep2mlwas07a>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	Alexander Drozdov <al.drozdov@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eyal Birger <eyal.birger@gmail.com>,
	"mst@redhat.com" <mst@redhat.com>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	PANKAJ MISHRA <pankaj.m@samsung.com>
To: Maninder Singh <maninder1.s@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35496 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbbFVHAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 03:00:52 -0400
In-Reply-To: <1504484104.41691434955982414.JavaMail.weblogic@ep2mlwas07a>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Jun 22, 2015 at 8:53 AM, Maninder Singh <maninder1.s@samsung.com> wrote:
> Hi Frans,
>
>>> v1 = replace if()/BUG with BUG_ON() for tx_ring.
>>>
>>> v2 =
>>
>>I would keep this below the ---. There's little historical use for
>>this version information when it gets merged.
>>
>>> remove handling of tx_ring in prb_setup_retire_blk_timer
>>> for TPACKET_V3 because init_prb_bdqc is called only for NULL tx_ring
>>> and thus prb_setup_retire_blk_timer for NULL tx_ring only.
>>
>>I'd say tx_ring is false, rather than NULL. It's not a pointer (here).
>>
>>
>>> And also in funciton init_prb_bdqc there is no usage of tx_ring.
>>
>>s,funciton,function,
>
> Thanks for feedback , please check below changelog if it looks ok,
> Then i will share updated patch:-
>
> v1 = replace if()/BUG with BUG_ON() for tx_ring.
>
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> Signed-off-by: Frans Klaver <fransklaver@gmail.com>

No, the Suggested-by: was better for me. You can't go about and add
Signed-off-by lines for someone else without permission ;-).

> ---
> Changes in v2:
>
>  Remove handling of tx_ring in prb_setup_retire_blk_timer
>  for TPACKET_V3 because init_prb_bdqc is called only for zero tx_ring
>  and thus prb_setup_retire_blk_timer for zero tx_ring only.
>
>  And also in functon init_prb_bdqc there is no usage of tx_ring.
>  Thus removing tx_ring from init_prb_bdqc.
>
>  net/packet/af_packet.c |   14 +++++---------
>  1 file changed, 5 insertions(+), 9 deletions(-)
>
>  Thanks
>  Maninder

No, I didn't make myself clear enough, I'm afraid. The info about the
different incarnations of your patch should go below the dashes. The
whole "Remove handling ...." text should be your commit message,
because that is what you want to see in the commit log. Here's an
example:

Subject: [RFC PATCH v2] packet: remove handling of tx_ring

Remove handling of tx_ring in prb_setup_retire_blk_timer for
TPACKET_V3 because init_prb_bdqc is called only for zero tx_ring and
thus prb_setup_retire_blk_timer for zero tx_ring only.

And also in functon init_prb_bdqc there is no usage of tx_ring. Thus
removing tx_ring from init_prb_bdqc.

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Suggested-by: Frans Klaver <fransklaver@gmail.com>
---
v1..v2: remove BUG() by removing tx_path

diffstat & patch
