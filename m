From: Frans Klaver <fransklaver@gmail.com>
Subject: Re: [RESUBMIT Patch 1/1] net: replace if()/BUG with BUG_ON
Date: Wed, 17 Jun 2015 10:30:18 +0200
Message-ID: <CAH6sp9PzTkNd88+ExRX1FTNNC=wC+jjOdL5urmtoyc5iz-pZTQ@mail.gmail.com>
References: <1434515761-14796-1-git-send-email-maninder1.s@samsung.com>
	<CAH6sp9M=DABEgO2yS+cSSBfNJiwP6wxecWVtMTpb9P_rrcadCw@mail.gmail.com>
	<55812F32.5030306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maninder Singh <maninder1.s@samsung.com>, davem@davemloft.net,
	willemb@google.com, dborkman@redhat.com,
	Al Viro <viro@zeniv.linux.org.uk>, eyal.birger@gmail.com,
	mst@redhat.com, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	pankaj.m@samsung.com
To: Alexander Drozdov <al.drozdov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55812F32.5030306@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 17, 2015 at 10:26 AM, Alexander Drozdov
<al.drozdov@gmail.com> wrote:
> On Wed, 17 Jun 2015 09:36:11 +0200, Frans Klaver wrote:
>>
>> On Wed, Jun 17, 2015 at 6:36 AM, Maninder Singh <maninder1.s@samsung.com>
>> wrote:
>>>
>>> Use BUG_ON(condition) instead of if(condition)/BUG() .
>>>
>>> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
>>> Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>
>>> ---
>>>   net/packet/af_packet.c |    3 +--
>>>   1 files changed, 1 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>>> index b5989c6..c91d405 100644
>>> --- a/net/packet/af_packet.c
>>> +++ b/net/packet/af_packet.c
>>> @@ -547,8 +547,7 @@ static void prb_setup_retire_blk_timer(struct
>>> packet_sock *po, int tx_ring)
>>>   {
>>>          struct tpacket_kbdq_core *pkc;
>>>
>>> -       if (tx_ring)
>>> -               BUG();
>>> +       BUG_ON(tx_ring);
>>>
>>>          pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring) :
>>>                          GET_PBDQC_FROM_RB(&po->rx_ring);
>>
>>
>> I don't get this. We're not allowed to be using tx_ring, but we can
>> and do handle it? Does that still warrant a BUG() or BUG_ON()? It's
>> been in since the function introduction[0]. Can somebody explain?
>
>
> TPACKET_V3 doesn't support tx for now, so the function is actualy never
> called with non-zero tx_ring. I think there were plans to add the
> support. But retire timer for tx will not be needed anyway as it is
> up to user to fill the ring buffer.

Ah, that explains something. If retire timer is not going to be needed
for tx, wouldn't it be better to remove the whole tx_ring handling
from this function altogether, rather than changing the BUG()?

Thanks,
Frans
