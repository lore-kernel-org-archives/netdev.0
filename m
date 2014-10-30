From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net] gre: Fix regression in gretap TSO support
Date: Thu, 30 Oct 2014 08:32:16 -0700
Message-ID: <54525A00.6070303@redhat.com>
References: <20141030032430.4452.46388.stgit@ahduyck-workstation.home>	<CALnjE+oK-O-PJH_u50HqQQLnvh+GyeCnv6tNQf5qzL0o1RiPQg@mail.gmail.com>	<CADVnQykSY_Q3HL0T1uNO4iUheWTpTsLLF7gCnM4SbJyGp3x6Wg@mail.gmail.com>	<54524B6A.3000503@redhat.com> <CA+mtBx_AAexNNktyZDFFZwqzgEh_FJbdekvtYVLn7cc2AGLFqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52421 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161100AbaJ3Pca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 11:32:30 -0400
In-Reply-To: <CA+mtBx_AAexNNktyZDFFZwqzgEh_FJbdekvtYVLn7cc2AGLFqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/30/2014 08:05 AM, Tom Herbert wrote:
> On Thu, Oct 30, 2014 at 7:30 AM, Alexander Duyck
> <alexander.h.duyck@redhat.com> wrote:
>> On 10/30/2014 06:51 AM, Neal Cardwell wrote:
>>> On Thu, Oct 30, 2014 at 1:14 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>>>> On Wed, Oct 29, 2014 at 8:26 PM,  <alexander.duyck@gmail.com> wrote:
>>>>> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>>>>>
>>>>> On recent kernels I found that TSO on gretap interfaces didn't work.
>>>>> After
>>>>> bisecting it I found that commit b884b1a4 had introduced a regression in
>>>>> which the Ethernet header was being included in the GRE header length.
>>>>>
>>>>> This change corrects that by basing the GRE header length on the inner
>>>>> mac
>>>>> header in the case of GRE tunnels using transparent Ethernet bridging,
>>>>> and
>>>>> uses the network header for all other GRE tunnel types.
>>>>>
>>>>> Fixes: b884b1a4 ("gre_offload: simplify GRE header length calculation in
>>>>> gre_gso_segment()")
>>> Hmm. There may be other protocols, either now or in the future, where
>>> we want to be able to have a mac header inside the GRE header, rather
>>> than a network header. AFAICT it would be safer to revert b884b1a4,
>>> and go back to the previous code (from c50cd357), where we parse the
>>> GRE header to figure out its length.
>>>
>>> neal
>>
>> The change is consistent with how we handle this in other spots throughout
>> the kernel.  If nothing else you can just search for ETH_P_TEB and you will
>> find multiple spots in the kernel where IP tunnels differentiate between
>> transparent Ethernet bridging and regular IP in IP tunnels by checking for
>> the protocol ETH_P_TEB.
>>
> I'm not sure I understand this. We always use inner mac header in
> __skb_udp_tunnel_segment for computing tunnel length and don't
> distinguish between Ethernet or IP encapsulation. Presumably, in the
> case of IP encapsulation inner mac header is equal to inner network
> header. Why is this different for GRE?
>
> Thanks,
> Tom

I'll dig into that a bit more and see if I can simplify this.  I just 
wasn't sure if the inner mac header was being initialized or not in the 
case of IP in IP tunnels.

Thanks,

Alex
