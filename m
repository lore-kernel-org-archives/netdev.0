From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC 01/01]af_packet: Enhance network capture visibility
Date: Wed, 25 May 2011 19:24:21 -0400
Message-ID: <BANLkTim8WXiSEc2_KJVULKz4iVQO7yxt5A@mail.gmail.com>
References: <BANLkTimYVUkUWA2XPix2nUL-=rnQKghZQA@mail.gmail.com>
	<4DDD8C5E.7040207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, loke.chetan@gmail.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f173.google.com ([209.85.212.173]:55717 "EHLO
	mail-px0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab1EYXYW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 19:24:22 -0400
Received: by pxi16 with SMTP id 16so94624pxi.4
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 16:24:21 -0700 (PDT)
In-Reply-To: <4DDD8C5E.7040207@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2011 at 7:10 PM, Ben Greear <greearb@candelatech.com> w=
rote:
> On 05/25/2011 04:03 PM, chetan loke wrote:
>>
>> This patch is not complete and is intended to:
>> a) demonstrate the improvments
>> b) gather suggestions
>>
>>
>> Signed-off-by: Chetan Loke<lokec@ccs.neu.edu>
>
>> +struct tpacket3_hdr {
>> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 tp_status;
>> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 tp_len;
>> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 tp_snaplen;
>> + =A0 =A0 =A0 __u16 =A0 =A0 =A0 =A0 =A0 tp_mac;
>> + =A0 =A0 =A0 __u16 =A0 =A0 =A0 =A0 =A0 tp_net;
>> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 tp_sec;
>> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 tp_nsec;
>> + =A0 =A0 =A0 __u16 =A0 =A0 =A0 =A0 =A0 tp_vlan_tci;
>> + =A0 =A0 =A0 long =A0 =A0 =A0 =A0 =A0 =A0tp_next_offset;
>> +};
>
> Use fixed-size variables, like __u64 instead of 'long'. =A0That way,
> you have the same sized msgs on 32 and 64-bit systems.
>

Thanks Ben.


The intent is to also introduce something like

typedef struct {
		uint64_t pkt_sliced:1;
		uint64_t crc_error:1;
		uint64_t code_violation:1; /* if frame had code violation */
		uint64_t num_mpls_labels:4;
		uint64_t num_vlans:3;
		uint64_t l2_type:6;
		uint64_t l3_type:4;
		uint64_t l4_type:4;
		uint64_t l7_type:8;
		uint64_t rsvd:32;
}feature_s1;

typedef struct {
	union {
		feature_s1 f_s1;
               /* future feature goes here */
	}u1;
}feature_variants;

And then embed feature_variants in the pkt_desc.


Once we have the proposed non-static frame format in place then I am
hoping some vendor can borrow this format, enhance their capture
driver and DMA the data directly in the block. This way we can also
attempt to standardize the block-capture format on linux and make it
easier for smaller FPGA shops.


>
> Thanks,
> Ben
>

Chetan
