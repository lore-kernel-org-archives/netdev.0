From: Ryota Ozaki <ozaki.ryota@gmail.com>
Subject: Re: [PATCH] doc: fix wrongly referencing dev->skb_mark
Date: Wed, 12 Oct 2016 00:47:39 +0900
Message-ID: <CAKrYomi4otAHxZ17VLZXi7c37xAVdq_3vzHAwQQPeo2pPkkbkQ@mail.gmail.com>
References: <1476098139-6333-1-git-send-email-ozaki.ryota@gmail.com> <20161010134943.GA8090@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36493 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752854AbcJKPsS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 11:48:18 -0400
Received: by mail-qk0-f195.google.com with SMTP id z190so1720789qkc.3
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 08:48:00 -0700 (PDT)
In-Reply-To: <20161010134943.GA8090@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 10:49 PM, Ido Schimmel <idosch@idosch.org> wrote:
> Hi,
>
> On Mon, Oct 10, 2016 at 08:15:39PM +0900, Ryota Ozaki wrote:
>> Section "Flooding L2 domain" says, to avoid duplicated flooding, if
>> skb->offload_fwd_mark is matched with dev->skb_mark, the kernel will
>> drop the packet. However, the relevant code in __dev_queue_xmit
>> compares skb->offload_fwd_mark with dev->offload_fwd_mark, not
>> dev->skb_mark. I guess the text is wrong.
>>
>> Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
>> ---
>>  Documentation/networking/switchdev.txt | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
>> index 31c3911..d4124a0 100644
>> --- a/Documentation/networking/switchdev.txt
>> +++ b/Documentation/networking/switchdev.txt
>> @@ -286,8 +286,8 @@ otherwise there will be duplicate packets on the wire.
>>  To avoid duplicate packets, the device/driver should mark a packet as already
>>  forwarded using skb->offload_fwd_mark.  The same mark is set on the device
>>  ports in the domain using dev->offload_fwd_mark.  If the skb->offload_fwd_mark
>> -is non-zero and matches the forwarding egress port's dev->skb_mark, the kernel
>> -will drop the skb right before transmit on the egress port, with the
>> +is non-zero and matches the forwarding egress port's dev->offload_fwd_mark,
>> +the kernel will drop the skb right before transmit on the egress port, with the
>
> I think your tree isn't up to date. The flooding mechanism (and this
> document) were modified in commit 6bc506b4fb06 ("bridge: switchdev: Add
> forward mark support for stacked devices")
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6bc506b4fb065eac3d89ca1ce37082e174493d9e

Oh, right. I forgot to rebase my branch after the 4.9 merge period
and saw the file as of 4.8.

>
> Also, in the future, please specify to which tree (net, net-next) your
> patch should go. See:
> https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt
> (under "How do I indicate which tree (net vs. net-next) my patch
> should be in?").

Thanks for the pointer. I'll follow the rule next time.

Thanks,
  ozaki-r

>
> Thanks!
>
>>  understanding that the device already forwarded the packet on same egress port.
>>  The driver can use switchdev_port_fwd_mark_set() to set a globally unique mark
>>  for port's dev->offload_fwd_mark, based on the port's parent ID (switch ID) and
>> --
>> 2.7.4
>>
