From: Steve Ma <sma.fcoe@gmail.com>
Subject: Re: [Open-FCoE] Request for Advice from Steve Ma
Date: Thu, 4 Mar 2010 12:40:32 -0800
Message-ID: <4c10050b1003041240s69f4ee12id5096554a03f7dfa@mail.gmail.com>
References: <4c10050b1003010926y24a633f3od6a0e21f5de5b552@mail.gmail.com>
	 <4c10050b1003011131v128b8953x24582280825c1480@mail.gmail.com>
	 <4B8C17CB.4000107@cisco.com>
	 <4c10050b1003011154n7f429490n880bf65c59417bdb@mail.gmail.com>
	 <4B8C1EAC.7090408@cisco.com>
	 <4c10050b1003011303n4b348015jc37cf68eae3848bf@mail.gmail.com>
	 <4B8C422E.4080306@cisco.com>
	 <4c10050b1003011517s5fa84b94h86a8ec4ec8c1ebc7@mail.gmail.com>
	 <8F08A56613D77044BD153E2AC5DA0F8403C3E8D0@CORPUSMX40A.corp.emc.com>
	 <4B8EA858.8020308@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: berthiaume_wayne@emc.com, devel@open-fcoe.org,
	netdev@vger.kernel.org
To: Joe Eykholt <jeykholt@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:47313 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756448Ab0CDUke convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 15:40:34 -0500
Received: by fxm19 with SMTP id 19so3311949fxm.21
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 12:40:32 -0800 (PST)
In-Reply-To: <4B8EA858.8020308@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 3, 2010 at 10:20 AM, Joe Eykholt <jeykholt@cisco.com> wrote=
:
> berthiaume_wayne@emc.com wrote:
>>
>> Wouldn't it be better to pass this as part of the SCSI block so it w=
ould
>> be transport agnostic?
>
> I'm not sure I see what you mean.
>
> This is transport-specific already, where we're putting
> a FCP command together and sending it out via FCoE. =A0 When the NIC =
gets the
> sk_buff
> to send, it only has the FCP command and any meta-data in the sk_buff=
=2E
> =A0There's no
> access to the scsi_cmnd, if that's what you mean. =A0Putting a pointe=
r to that
> in
> the sk_buff would solve the problem, but seems like a layering proble=
m.
> What am I overlooking?
>
> See more comments at end.
>
>>
>> Regards,
>> Wayne.
>> -----Original Message-----
>> From: devel-bounces@open-fcoe.org [mailto:devel-bounces@open-fcoe.or=
g] On
>> Behalf Of Steve Ma
>> Sent: Monday, March 01, 2010 6:17 PM
>> To: Joe Eykholt
>> Cc: devel@open-fcoe.org
>> Subject: Re: [Open-FCoE] Request for Advice from Steve Ma
>>
>> On Mon, Mar 1, 2010 at 2:39 PM, Joe Eykholt <jeykholt@cisco.com> wro=
te:
>>>
>>> Steve Ma wrote:
>>>>
>>>> On Mon, Mar 1, 2010 at 12:08 PM, Joe Eykholt <jeykholt@cisco.com> =
wrote:
>>>>>
>>>>> Steve Ma wrote:
>>>>>>
>>>>>> On Mon, Mar 1, 2010 at 11:38 AM, Joe Eykholt <jeykholt@cisco.com=
>
>>>>>> wrote:
>>>>>>>
>>>>>>> Steve Ma wrote:
>>>>>>>>
>>>>>>>> On Mon, Mar 1, 2010 at 10:49 AM, Joe Eykholt <jeykholt@cisco.c=
om>
>>>>>>>> wrote:
>>>>>>>>>
>>>>>>>>> Steve Ma wrote:
>>>>>>>>>>
>>>>>>>>>> On Mon, Mar 1, 2010 at 10:06 AM, Robert Love
>>>>>>>>>> <robert.w.love@intel.com>
>>>>>>>>>> wrote:
>>>>>>>>>>>
>>>>>>>>>>> On Mon, 2010-03-01 at 10:04 -0800, Robert Love wrote:
>>>>>>>>>>>>
>>>>>>>>>>>> On Mon, 2010-03-01 at 09:26 -0800, Steve Ma wrote:
>>>>>>>>>>>>>
>>>>>>>>>>>>> Hi Guys,
>>>>>>>>>>>>>
>>>>>>>>>>>> Hi Steve
>>>>>>>>>>>>
>>>>>>>>>>>>> When the SCSI mid-layer passes a SCSI command to the Open=
-FCoE,
>>>>>>>>>>>>> the
>>>>>>>>>>>>> fc_queuecomamnd receives the pointer of struct scsi_cmnd.=
 This
>>>>>>>>>>>>> data
>>>>>>>>>>>>> structure contains two scatter-gather lists:
>>>>>>>>>>>>>
>>>>>>>>>>>>> =A0struct scsi_data_buffer sdb;
>>>>>>>>>>>>> =A0struct scsi_data_buffer *prot_sdb;
>>>>>>>>>>>>>
>>>>>>>>>>>>> The Open-FCoE stack does transmitting and receiving of sd=
b
>>>>>>>>>>>>> to/from
>>>>>>>>>>>>> the
>>>>>>>>>>>>> NIC driver. Now I am in need of transmitting and receivin=
g both
>>>>>>>>>>>>> of
>>>>>>>>>>>>> them to the NIC driver and, in addition, I also need to p=
ass
>>>>>>>>>>>>> down
>>>>>>>>>>>>> the
>>>>>>>>>>>>> return value of the mid layer routine
>>>>>>>>>>>>>
>>>>>>>>>>>>> =A0unsigned char scsi_get_prot_op(struct scsi_cmnd *scmd)
>>>>>>>>>>>>>
>>>>>>>>>>>>> What would be the best way to implement?
>>>>>>>>>>>>
>>>>>>>>>>>> At a high level you're going to need to go through netdev =
so
>>>>>>>>>>>> engaging
>>>>>>>>>>>> their mailing list would be a good start (CC'ing this list=
 would
>>>>>>>>>>>> be
>>>>>>>>>>>> nice). For FCoE offloaded devices that are netdev based we=
 have
>>>>>>>>>>>> these
>>>>>>>>>>>> routines in the netdev structure-
>>>>>>>>>>>
>>>>>>>>>>> This should say, "in struct net_device_ops."
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>> I have already seen those ndo routines. I may be able to mak=
e use
>>>>>>>>>> of
>>>>>>>>>> the DDP rotuines. But for transmit, I am still not sure what=
 the
>>>>>>>>>> best
>>>>>>>>>> way to do.
>>>>>>>>>>
>>>>>>>>>> Thanks
>>>>>>>>>> Steve
>>>>>>>>>
>>>>>>>>> Is the extra buffer descriptor for DIF bytes or what?
>>>>>>>>
>>>>>>>> Yes, there are 8-bytes of protection data for DIF/DIX.
>>>>>>>>
>>>>>>>>> How would it be supported and used in a non-offloaded case?
>>>>>>>>
>>>>>>>> Currently we are intended to do this in offloaded case.
>>>>>>>> I would disable the protection if offload (LSO/DDP) is disable=
d.
>>>>>>>>
>>>>>>>>> I mean, what would the code look like in fc_fcp.c?
>>>>>>>>
>>>>>>>> Not sure yet. I will try to make the code as simple as possibl=
e in
>>>>>>>> the
>>>>>>>> fcoe level, and do as much work as possible in the NIC driver =
and
>>>>>>>> the
>>>>>>>> ASIC.
>>>>>>>>
>>>>>>>>> What should the frames look like? =A0Would there just be addi=
tional
>>>>>>>>> DIF bytes sent/received after every so many data bytes? =A0If=
 so,
>>>>>>>>> would it work (from a protocol standpoint, maybe not efficien=
tly)
>>>>>>>>> to just merge the sg_lists?
>>>>>>>>
>>>>>>>> I have the same thought of merging the sglists, and in the NIC
>>>>>>>> driver
>>>>>>>> if I can figure out the correct pointer to the 8-bytes at the =
end, I
>>>>>>>> can assign an additional TxD for it. I am not sure if I have b=
etter
>>>>>>>> choice.
>>>>>>>
>>>>>>> If the NIC driver is just going to merge the SG lists, then why
>>>>>>> not do it at the fc_fcp layer? =A0That way it would work for th=
e
>>>>>>> non-offloaded case as well, and you wouldn't need any additiona=
l
>>>>>>> offload interfaces.
>>>>>>>
>>>>>>> =A0 =A0 Cheers,
>>>>>>> =A0 =A0 Joe
>>>>>>>
>>>>>>>
>>>>>> No, what I am thinking is to merge the two sglists in fc_fcp, th=
us the
>>>>>> 8-byte protection data will be part of the frame (skb) passed do=
wn to
>>>>>> the NIC driver.
>>>>>
>>>>> That's what I was suggesting. =A0I thought you were suggesting pa=
ssing
>>>>> both SG lists separately to the NIC. =A0Perhaps I misunderstood.
>>>>>
>>>>>> It will be a driver for our future NIC. In the NIC driver, I wil=
l have
>>>>>> to assign TxDs for the frame data, and an additional TxD for the
>>>>>> 8-byte. So to my understanding, the NIC driver is to separate th=
e
>>>>>> frame data and the 8-byte tag fields. I would let the ASIC to to=
 the
>>>>>> validation job for the protection data. If there is no-offload, =
the
>>>>>> validation would be a big performance burden if they are done in=
 the
>>>>>> OS driver.
>>>>>
>>>>> Wouldn't DIF need to be validated again when the data is used?
>>>>
>>>> This depends on the value returned from scsi_get_prot_op(). Either
>>>> OS<-->HBA is protected or HBA<-->Target is protected or both
>>>> (end-to-end). HBA is a checkpoint we are responsible for.
>>>>
>>>>> Otherwise other parts of the data path aren't covered ... the
>>>>> DIF wouldn't be completely end-to-end. =A0But verification at
>>>>> multiple points along the path is good.
>>>>>
>>>>> I was mostly thinking about sending the DIF where it's already
>>>>> been verified. =A0Receiving the DIF is more difficult since you
>>>>> don't know exactly how the data will be divided into frames,
>>>>> but it's the same effect: a merged SG list.
>>>>
>>>> With your support, this is the best approach I can work on.
>>>>
>>>> BTW. I want to pass the return value of scsi_get_prot_op() from fc=
_fcp
>>>> to the NIC driver during transmitting of a SCSI command, what woul=
d be
>>>> the best approach? It is only a byte.
>>>
>>> You could pass it to fcoe_xmit() or whatever LLD in the fcoe_rcv_in=
fo.
>>> There's only one byte free there (without stretching skb->cb[]),
>>> but you could encode it in fr_flags, which has 7 bits free.
>>> skb->cb[] can't be used for this outside of libfc/fcoe though,
>>> because it's allowed to be reused by any intermediate layers.
>>> But since skb->cb also contains the fr_fsp, you could put it in the=
re,
>>> and call scsi_get_prot_op() from the fcoe if needed.
>>>
>>> After fcoe_xmit(), prot_op could be passed to the NIC some other wa=
y.
>>> Perhaps by appending it after the data (to be stripped off later),
>>> or using some existing field in the sk_buff.
>>>
>>> This is a long-winded way of saying "I don't know." =A0Someone who
>>> deals more with the guts of sk_buffs will probably suggest somethin=
g.
>>>
>>> =A0 =A0 =A0 Joe
>>>
>>>
>>>
>> Appending seems to be a clean way to do. So I will have 9 bytes in
>> total appended to the data frame.
>>
>> Thanks
>> Steve
>
> I regret suggesting appending. =A0I no longer thing that's such a goo=
d idea.
> If it is after the FCoE Encapsulation, then it might be OK, but we wo=
uld
> have to know that the NIC will take it off. =A0Also, it will look wro=
ng
> for tcpdump.
>
> Look into other ways of attaching meta-data to sk_buffs. =A0There mig=
ht
> be something already available.
>
> =A0 =A0 =A0 =A0Joe
>
>
I'll keep on looking.
Thanks.
          Steve Ma
