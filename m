From: Tom Herbert <therbert@google.com>
Subject: Re: 3.3.0-rc5: OOps in dql_completed (Broadcom tg3 driver)
Date: Mon, 5 Mar 2012 21:14:12 -0800
Message-ID: <CA+mtBx8oiDq+k3U705xYaV3xUsi=DnSWwCkymEONRcX3su77Fg@mail.gmail.com>
References: <alpine.DEB.2.00.1203011505510.6685@router.home>
	<1330698646.2469.28.camel@edumazet-laptop>
	<CA+mtBx_vNcPr-q7FSKXCAsVqvjZt=4UpWfv5eAp0=diG0wnbjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@gentwo.org>, mcarlson@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+mtBx_vNcPr-q7FSKXCAsVqvjZt=4UpWfv5eAp0=diG0wnbjQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BQL implementation for tg3 does not handle multi queue correctly.
Will have a fix for that momentarily.

Tom

On Fri, Mar 2, 2012 at 9:23 AM, Tom Herbert <therbert@google.com> wrote=
:
> Hi Christoph, Eric,
>
> Looks like we're hitting BUG_ON(count > dql->num_queued -
> dql->num_completed). =A0This is indicative of mis-accounting occurrin=
g
> between netdev_sent_queue and netdev_completed_queue. =A0I don't
> immediately see how this could happen here in the tg3_tso_bug path,
> this is still using the same calls to transmit and complete as other
> paths. =A0I suppose it's possible that skb_gso_segment is somehow
> munging skb->len in segments.
>
> I'll try to reproduce this.
>
>> In case we hit BQL limit in one of the tg3_start_xmit() calls, we sh=
ould
>> 'abort' the following ones, dont you think ?
>
> I'm not sure what you mean Eric. =A0It should be okay to exceed the B=
QL
> limit up to the point that num_queued rolls over (probably should be =
a
> BUG_ON for that). =A0This is a much greater number than could ever be
> queued to tg3.
>
> Thanks,
> Tom
>
>>
>> Or maybe thats irrelevant, and only dql_queued() comment is wrong.
>>
>> Thanks
>>
>>
