From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH 1/1] rps: Inspect PPTP encapsulated by GRE to get flow hash
Date: Wed, 3 Aug 2016 23:02:23 +0800
Message-ID: <CA+6hz4rgz4t6m-3bJO8NBaBLaq7fMe67hbCGDSCLueq-3XQv+A@mail.gmail.com>
References: <1469690081-32122-1-git-send-email-fgao@ikuai8.com>
 <CALx6S35pZFPWk999qawU_mXYLymyJ7zh-xipcYetA6vz04=vJA@mail.gmail.com>
 <CA+6hz4qVM=bS_8fHx2HogHObbRsVpoRqLrk51FTPcbX38j2yxg@mail.gmail.com>
 <CALx6S344y8ze7Tp_yQ8yRW5YW2Vs6aY18HpKyE1L9Vq2VP9Yyg@mail.gmail.com>
 <CA+6hz4o8K4q1RuhndqqROAxN8x7pduvgwRqXRBvDxb29Ndy3NA@mail.gmail.com> <CALx6S37A4wZx7FNE15MtNRMuqeaHqSmhOugEQ1snapFRupY=HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@ikuai8.com>,
	"David S. Miller" <davem@davemloft.net>,
	Philp Prindeville <philipp@redfish-solutions.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:34428 "EHLO
	mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbcHCPDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 11:03:00 -0400
Received: by mail-ua0-f181.google.com with SMTP id 35so154460758uap.1
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 08:02:24 -0700 (PDT)
In-Reply-To: <CALx6S37A4wZx7FNE15MtNRMuqeaHqSmhOugEQ1snapFRupY=HQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Philip & Tom,

I have sent the v3 patch now.

Philip,
I just move the definition of pptp_gre_header into new file
include/net/pptp.h without refactoring the pptp codes now.
I think the refactor should be done in another patch.

Tom,
Now I have consolidate the PPTP codes with GRE codes together.

Thanks both of you :-))

On Wed, Aug 3, 2016 at 12:01 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Aug 2, 2016 at 7:17 PM, Feng Gao <gfree.wind@gmail.com> wrote:
>> Thanks Tom's detail explanation.
>> It is my misinterpret because my mother language is not English.
>>
> No, the RFC is somewhat poorly worded with respect to setting the
> version number. The fact that flag bit must be set to zero on
> transmit, but can be processed on received is permitted by
> "legalistic" interpretation of an IETF RFC :-)
>
> Tom
>
>> Thanks again:))
>>
>> On Wed, Aug 3, 2016 at 9:59 AM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Tue, Aug 2, 2016 at 5:28 PM, Feng Gao <gfree.wind@gmail.com> wrote:
>>>> Hi Tom.
>>>>
>>>> I quote some description in RFC 2637.
>>>>
>>>> /*********************************************************************/
>>>>    C
>>>>       (Bit 0) Checksum Present.  Set to zero (0).
>>>>
>>> Note that the requirement is "*Set* to zero"; it is not must check to
>>> be zero on reception. Per the robustness principle (part about be
>>> liberal in what you receive) it is allowable to process the flag if
>>> the bit is set set. In practice this is nice to have because we know
>>> that overloading fields in GRE (seq, csum in particular) with private
>>> data has been done before. Consolidating makes for cleaner code, and
>>> if someone is really violating the protocol the worst thing that would
>>> happen it that they would just get suboptimal RPS for those packets.
>>>
>>>>    R
>>>>       (Bit 1) Routing Present.  Set to zero (0).
>>>>
>>>>    K
>>>>       (Bit 2) Key Present.  Set to one (1).
>>>>    S
>>>>       (Bit 3) Sequence Number Present.  Set to one (1) if a payload
>>>>       (data) packet is present.  Set to zero (0) if payload is not
>>>>       present (GRE packet is an Acknowledgment only).
>>>>
>>>>    s
>>>>       (Bit 4) Strict source route present.  Set to zero (0).
>>>>
>>>>    Recur
>>>>       (Bits 5-7) Recursion control.  Set to zero (0).
>>>>
>>>>    A
>>>>       (Bit 8) Acknowledgment sequence number present.  Set to one (1) if
>>>>       packet contains Acknowledgment Number to be used for acknowledging
>>>>       previously transmitted data.
>>>>
>>>>    Flags
>>>>       (Bits 9-12) Must be set to zero (0).
>>>>
>>>>    Ver
>>>>       (Bits 13-15) Must contain 1 (enhanced GRE).
>>>>
>>>>    Protocol Type
>>>>       Set to hex 880B [8].
>>>>
>>>>    Key
>>>>       Use of the Key field is up to the implementation.  PPTP uses it as
>>>>       follows:
>>>>          Payload Length
>>>>             (High 2 octets of Key) Size of the payload, not including
>>>>             the GRE header
>>>>
>>>>          Call ID
>>>>             (Low 2 octets) Contains the Peer's Call ID for the session
>>>>             to which this packet belongs.
>>>> /*********************************************************************/
>>>>
>>>> Just a reminder, the version description is "contain 1", not "set 1".
>>>>
>>> I think your misinterpreting that (at least I hope :-) ). "Contains 1"
>>> should be that the contents of the Ver field is the value of "1".
>>> Otherwise, the RFC has appropriated half of the eight possible
>>> versions to be enhanced GRE.
>>>
>>> Tom
>>>
>>>> Best Regards
>>>> Feng
>>>>
>>>> On Wed, Aug 3, 2016 at 4:35 AM, Tom Herbert <tom@herbertland.com> wrote:
>>>>> On Thu, Jul 28, 2016 at 12:14 AM,  <fgao@ikuai8.com> wrote:
>>>>>> From: Gao Feng <fgao@ikuai8.com>
>>>>>>
>>>>>> The PPTP is encapsulated by GRE header with that GRE_VERSION bits
>>>>>> must contain one. But current GRE RPS needs the GRE_VERSION must be
>>>>>> zero. So RPS does not work for PPTP traffic.
>>>>>>
>>>>>> In my test environment, there are four MIPS cores, and all traffic
>>>>>> are passed through by PPTP. As a result, only one core is 100% busy
>>>>>> while other three cores are very idle. After this patch, the usage
>>>>>> of four cores are balanced well.
>>>>>>
>>>>>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>>>>>> ---
>>>>>>  v2: Update according to Tom and Philp's advice.
>>>>>>      1) Consolidate the codes with GRE version 0 path;
>>>>>>      2) Use PPP_PROTOCOL to get ppp protol;
>>>>>>      3) Set the FLOW_DIS_ENCAPSULATION flag;
>>>>>>  v1: Initial patch
>>>>>>
>>>>>>  include/uapi/linux/if_tunnel.h |   5 +-
>>>>>>  net/core/flow_dissector.c      | 146 ++++++++++++++++++++++++++---------------
>>>>>>  2 files changed, 97 insertions(+), 54 deletions(-)
>>>>>>
>>>>>> diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
>>>>>> index 1046f55..dda4e4b 100644
>>>>>> --- a/include/uapi/linux/if_tunnel.h
>>>>>> +++ b/include/uapi/linux/if_tunnel.h
>>>>>> @@ -24,9 +24,12 @@
>>>>>>  #define GRE_SEQ                __cpu_to_be16(0x1000)
>>>>>>  #define GRE_STRICT     __cpu_to_be16(0x0800)
>>>>>>  #define GRE_REC                __cpu_to_be16(0x0700)
>>>>>> -#define GRE_FLAGS      __cpu_to_be16(0x00F8)
>>>>>> +#define GRE_ACK                __cpu_to_be16(0x0080)
>>>>>> +#define GRE_FLAGS      __cpu_to_be16(0x0078)
>>>>>>  #define GRE_VERSION    __cpu_to_be16(0x0007)
>>>>>>
>>>>>> +#define GRE_PROTO_PPP  __cpu_to_be16(0x880b)
>>>>>> +
>>>>>>  struct ip_tunnel_parm {
>>>>>>         char                    name[IFNAMSIZ];
>>>>>>         int                     link;
>>>>>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>>>>>> index 61ad43f..33e957b 100644
>>>>>> --- a/net/core/flow_dissector.c
>>>>>> +++ b/net/core/flow_dissector.c
>>>>>> @@ -346,63 +346,103 @@ ip_proto_again:
>>>>>>                 hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
>>>>>>                 if (!hdr)
>>>>>>                         goto out_bad;
>>>>>> -               /*
>>>>>> -                * Only look inside GRE if version zero and no
>>>>>> -                * routing
>>>>>> -                */
>>>>>> -               if (hdr->flags & (GRE_VERSION | GRE_ROUTING))
>>>>>> -                       break;
>>>>>> -
>>>>>> -               proto = hdr->proto;
>>>>>> -               nhoff += 4;
>>>>>> -               if (hdr->flags & GRE_CSUM)
>>>>>> -                       nhoff += 4;
>>>>>> -               if (hdr->flags & GRE_KEY) {
>>>>>> -                       const __be32 *keyid;
>>>>>> -                       __be32 _keyid;
>>>>>> -
>>>>>> -                       keyid = __skb_header_pointer(skb, nhoff, sizeof(_keyid),
>>>>>> -                                                    data, hlen, &_keyid);
>>>>>>
>>>>>> -                       if (!keyid)
>>>>>> -                               goto out_bad;
>>>>>> +               /* Only look inside GRE without routing */
>>>>>> +               if (!(hdr->flags & GRE_ROUTING)) {
>>>>>> +                       proto = hdr->proto;
>>>>>> +
>>>>>> +                       if (hdr->flags & GRE_VERSION) {
>>>>>
>>>>> This matches any non-zero GRE version (1-7). Is that really what you want?
>>>>>
>>>>>> +                               /* It should be the PPTP in GRE */
>>>>>> +                               u8 _ppp_hdr[PPP_HDRLEN];
>>>>>> +                               u8 *ppp_hdr;
>>>>>> +                               int offset = 0;
>>>>>> +
>>>>>> +                               /* Check the flags according to RFC 2637*/
>>>>>> +                               if (!(proto == GRE_PROTO_PPP && (hdr->flags & GRE_KEY) &&
>>>>>> +                                     !(hdr->flags & (GRE_CSUM | GRE_STRICT | GRE_REC | GRE_FLAGS)))) {
>>>>>> +                                       break;
>>>>>> +                               }
>>>>>> +
>>>>> I might be missing something, but I only see two material differences
>>>>> between v0 and v1 of GRE. First is that keyid in v1 has specific use
>>>>> that is not appropriate to use as entropy. Second is how the payload
>>>>> is parsed. All the flag processing is common so it stills seems like
>>>>> this should be consolidated.
>>>>>
>>>>>> +                               /* Skip GRE header */
>>>>>> +                               offset += 4;
>>>>>> +                               /* Skip payload length and call id */
>>>>>> +                               offset += 4;
>>>>>> +
>>>>>> +                               if (hdr->flags & GRE_SEQ)
>>>>>> +                                       offset += 4;
>>>>>> +
>>>>>> +                               if (hdr->flags & GRE_ACK)
>>>>>> +                                       offset += 4;
>>>>>> +
>>>>>> +                               ppp_hdr = skb_header_pointer(skb, nhoff + offset, sizeof(_ppp_hdr), _ppp_hdr);
>>>>>> +                               if (!ppp_hdr)
>>>>>> +                                       goto out_bad;
>>>>>> +                               proto = PPP_PROTOCOL(ppp_hdr);
>>>>>> +                               if (proto == PPP_IP) {
>>>>>> +                                       nhoff += (PPP_HDRLEN + offset);
>>>>>> +                                       proto = htons(ETH_P_IP);
>>>>>> +                                       key_control->flags |= FLOW_DIS_ENCAPSULATION;
>>>>>> +                                       goto again;
>>>>>> +                               } else if (proto == PPP_IPV6) {
>>>>>> +                                       nhoff += (PPP_HDRLEN + offset);
>>>>>> +                                       proto = htons(ETH_P_IPV6);
>>>>>> +                                       key_control->flags |= FLOW_DIS_ENCAPSULATION;
>>>>>> +                                       goto again;
>>>>>> +                               }
>>>>>> +                       } else {
>>>>>> +                               /* Original GRE */
>>>>>> +                               nhoff += 4;
>>>>>> +                               if (hdr->flags & GRE_CSUM)
>>>>>> +                                       nhoff += 4;
>>>>>> +                               if (hdr->flags & GRE_KEY) {
>>>>>> +                                       const __be32 *keyid;
>>>>>> +                                       __be32 _keyid;
>>>>>> +
>>>>>> +                                       keyid = __skb_header_pointer(skb, nhoff, sizeof(_keyid),
>>>>>> +                                                                    data, hlen, &_keyid);
>>>>>> +
>>>>>> +                                       if (!keyid)
>>>>>> +                                               goto out_bad;
>>>>>> +
>>>>>> +                                       if (dissector_uses_key(flow_dissector,
>>>>>> +                                                              FLOW_DISSECTOR_KEY_GRE_KEYID)) {
>>>>>> +                                               key_keyid = skb_flow_dissector_target(flow_dissector,
>>>>>> +                                                                                     FLOW_DISSECTOR_KEY_GRE_KEYID,
>>>>>> +                                                                                     target_container);
>>>>>> +                                               key_keyid->keyid = *keyid;
>>>>>> +                                       }
>>>>>> +                                       nhoff += 4;
>>>>>> +                               }
>>>>>> +                               if (hdr->flags & GRE_SEQ)
>>>>>> +                                       nhoff += 4;
>>>>>> +                               if (proto == htons(ETH_P_TEB)) {
>>>>>> +                                       const struct ethhdr *eth;
>>>>>> +                                       struct ethhdr _eth;
>>>>>> +
>>>>>> +                                       eth = __skb_header_pointer(skb, nhoff,
>>>>>> +                                                                  sizeof(_eth),
>>>>>> +                                                                  data, hlen, &_eth);
>>>>>> +                                       if (!eth)
>>>>>> +                                               goto out_bad;
>>>>>> +                                       proto = eth->h_proto;
>>>>>> +                                       nhoff += sizeof(*eth);
>>>>>> +
>>>>>> +                                       /* Cap headers that we access via pointers at the
>>>>>> +                                        * end of the Ethernet header as our maximum alignment
>>>>>> +                                        * at that point is only 2 bytes.
>>>>>> +                                        */
>>>>>> +                                       if (NET_IP_ALIGN)
>>>>>> +                                               hlen = nhoff;
>>>>>> +                               }
>>>>>> +
>>>>>> +                               key_control->flags |= FLOW_DIS_ENCAPSULATION;
>>>>>> +                               if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
>>>>>> +                                       goto out_good;
>>>>>>
>>>>>> -                       if (dissector_uses_key(flow_dissector,
>>>>>> -                                              FLOW_DISSECTOR_KEY_GRE_KEYID)) {
>>>>>> -                               key_keyid = skb_flow_dissector_target(flow_dissector,
>>>>>> -                                                                     FLOW_DISSECTOR_KEY_GRE_KEYID,
>>>>>> -                                                                     target_container);
>>>>>> -                               key_keyid->keyid = *keyid;
>>>>>> +                               goto again;
>>>>>>                         }
>>>>>> -                       nhoff += 4;
>>>>>> -               }
>>>>>> -               if (hdr->flags & GRE_SEQ)
>>>>>> -                       nhoff += 4;
>>>>>> -               if (proto == htons(ETH_P_TEB)) {
>>>>>> -                       const struct ethhdr *eth;
>>>>>> -                       struct ethhdr _eth;
>>>>>> -
>>>>>> -                       eth = __skb_header_pointer(skb, nhoff,
>>>>>> -                                                  sizeof(_eth),
>>>>>> -                                                  data, hlen, &_eth);
>>>>>> -                       if (!eth)
>>>>>> -                               goto out_bad;
>>>>>> -                       proto = eth->h_proto;
>>>>>> -                       nhoff += sizeof(*eth);
>>>>>> -
>>>>>> -                       /* Cap headers that we access via pointers at the
>>>>>> -                        * end of the Ethernet header as our maximum alignment
>>>>>> -                        * at that point is only 2 bytes.
>>>>>> -                        */
>>>>>> -                       if (NET_IP_ALIGN)
>>>>>> -                               hlen = nhoff;
>>>>>>                 }
>>>>>> -
>>>>>> -               key_control->flags |= FLOW_DIS_ENCAPSULATION;
>>>>>> -               if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
>>>>>> -                       goto out_good;
>>>>>> -
>>>>>> -               goto again;
>>>>>> +               break;
>>>>>>         }
>>>>>>         case NEXTHDR_HOP:
>>>>>>         case NEXTHDR_ROUTING:
>>>>>> --
>>>>>> 1.9.1
>>>>>>
