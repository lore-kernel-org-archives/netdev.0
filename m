From: "Singhai, Anjali" <anjali.singhai@intel.com>
Subject: Re: [PATCH v3 2/4] i40e: geneve tunnel offload support
Date: Tue, 8 Dec 2015 15:08:22 -0800
Message-ID: <566762E6.7050505@intel.com>
References: <1449598334-97674-1-git-send-email-anjali.singhai@intel.com>
 <1449598334-97674-3-git-send-email-anjali.singhai@intel.com>
 <20151208182005.GB77166@ast-mbp.thefacebook.com>
 <CAEh+42jr+8Q65Zp0A+NE3jZSBe5nvnbaT6Zpx_JUHG0=MOUVhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	jeffrey.t.kirsher@intel.org, Kiran Patil <kiran.patil@intel.com>,
	Tom Herbert <tom@herbertland.com>
To: Jesse Gross <jesse@kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29730 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbbLHXIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 18:08:23 -0500
In-Reply-To: <CAEh+42jr+8Q65Zp0A+NE3jZSBe5nvnbaT6Zpx_JUHG0=MOUVhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/8/2015 10:36 AM, Jesse Gross wrote:
> On Tue, Dec 8, 2015 at 10:20 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Tue, Dec 08, 2015 at 10:12:12AM -0800, Anjali Singhai Jain wrote:
>>> +/**
>>> + * i40e_add_geneve_port - Get notifications about GENEVE ports that come up
>>> + * @netdev: This physical port's netdev
>>> + * @sa_family: Socket Family that GENEVE is notifying us about
>>> + * @port: New UDP port number that GENEVE started listening to
>>> + **/
>>> +static void i40e_add_geneve_port(struct net_device *netdev,
>>> +                              sa_family_t sa_family, __be16 port)
>>> +{
>>> +#if IS_ENABLED(CONFIG_GENEVE)
>> ...
>>> +     /* New port: add it and mark its index in the bitmap */
>>> +     pf->udp_ports[next_idx].index = port;
>>> +     pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_NGE;
>> the function suppose to deal with geneve but tunnel type is NGE ?!
> NGE is an old name for Geneve: "Next Generation Encapsulation"
Yes and that is why the old name in the SW/FW header files.
>>> -#define I40E_MAX_TUNNEL_HDR_LEN 80
>>> +/* Hardware supports L4 tunnel length of 128B (=2^7) which includes
>>> + * inner mac plus all inner ethertypes.
>>> + */
>>> +#define I40E_MAX_TUNNEL_HDR_LEN 128
>> so the driver lied about actual hw capabilities earlier
>> or it needs firmware update to work this way?
> I'm pretty sure that this is just making the calculation match the
> hardware more accurately. If you look at the code below it, it is now
> calculating the length from a different place.
It is making the code match the HW more accurately, which did support 
the 128 size
all along but till we enabled geneve support in the SW and FW,  the 
earlier setting was the right value.
>
>>> -     if (!(tx_flags & I40E_TX_FLAGS_VXLAN_TUNNEL)) {
>>> +     if (!(tx_flags & I40E_TX_FLAGS_UDP_TUNNEL)) {
>> ...
>>> @@ -163,7 +163,7 @@ enum i40e_dyn_idx_t {
>>>   #define I40E_TX_FLAGS_FSO            BIT(7)
>>>   #define I40E_TX_FLAGS_TSYN           BIT(8)
>>>   #define I40E_TX_FLAGS_FD_SB          BIT(9)
>>> -#define I40E_TX_FLAGS_VXLAN_TUNNEL   BIT(10)
>>> +#define I40E_TX_FLAGS_UDP_TUNNEL     BIT(10)
>> these changes implying that HW actually doesn't have special 'geneve or vxlan'
>> hard coded logic and it's generic enough to understand most of udp tunnels.
>> Then why you cannot generalize this whole things as generic udp tunnel offload
>> and do not add any protocol specific hooks and ndos.
> These are transmit flags but the issue of specialization relates to receive.
Second what Jesse said.
