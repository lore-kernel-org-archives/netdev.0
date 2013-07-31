From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: sendmsg() and vlan tags
Date: Wed, 31 Jul 2013 14:01:35 -0700
Message-ID: <CAOxq_8OZfeN+HxF715F0wAS5Pwuwd+6oAS3pZ9ueVJLfo1v0uw@mail.gmail.com>
References: <CAOxq_8Ni_WszNj0RW++2jdmLwBxbQCJSSC-AS1Ux5TgMEpd2iA@mail.gmail.com>
 <CAOxq_8PW9ggzOeoXJGxP1+48O=0A=5HAdpP9JJoe_iz=a2vgtw@mail.gmail.com> <1375232206.10515.48.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:62128 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757481Ab3GaVB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 17:01:56 -0400
Received: by mail-oa0-f44.google.com with SMTP id l20so2611233oag.17
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 14:01:55 -0700 (PDT)
In-Reply-To: <1375232206.10515.48.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 5:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-07-30 at 17:29 -0700, Ani Sinha wrote:
>> hello folks.
>>
>> Can anyone please shed lights on this?
>>
>> thanks,
>> ani
>>
>>
>> On Fri, Jul 26, 2013 at 2:30 PM, Ani Sinha <ani@aristanetworks.com> wrote:
>> > Hi folks,
>> >
>> > We know that (since Linux 3.0) on raw sockets, the recvmsg() api
>> > returns the vlan tag information of the packet in the packet aux data.
>> > I looked at the kernel code and it seems on the TX side, in sendmsg(),
>> > we do not accept the vlan tag data from userland for a raw packet. So
>> > if the userland sends a raw packet using sendmsg() with vlan tag
>> > information in aux data, it will be discarded.
>
>
> What is the vlan tag information value in aux data ?
>

It populates tp_vlan_tci field in the aux data (tpacket_auxdata
structure). Specifically, it gets the packet vlan tag ID and vlan
priority fields (PCP) from the skb.

In net/packet/af_packet.c :


a3bcc23e        (Ben Greear     2011-06-01 06:49:10 +0000       2822)
         if (vlan_tx_tag_present(skb)) {
a3bcc23e        (Ben Greear     2011-06-01 06:49:10 +0000       2823)
                 aux.tp_vlan_tci = vlan_tx_tag_get(skb);
a3bcc23e        (Ben Greear     2011-06-01 06:49:10 +0000       2824)
                 aux.tp_status |= TP_STATUS_VLAN_VALID;
a3bcc23e        (Ben Greear     2011-06-01 06:49:10 +0000       2825)
         } else {
a3bcc23e        (Ben Greear     2011-06-01 06:49:10 +0000       2826)
                 aux.tp_vlan_tci = 0;
a3bcc23e        (Ben Greear     2011-06-01 06:49:10 +0000       2827)
         }


The question is, on TX, can the user populate these values in the aux
data of a raw packet and do a sendmsg(). Will the kernel retain these
values. It looks like it does not.

-- 
Ani
