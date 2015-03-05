From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 05 Mar 2015 11:28:19 +0900
Message-ID: <54F7BF43.80203@lab.ntt.co.jp>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:58925 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408AbbCEC2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 21:28:40 -0500
In-Reply-To: <54F77336.7040006@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/03/05 6:03, Alexei Starovoitov wrote:
> On 3/4/15 12:41 PM, Michal Sekletar wrote:
>> This commit introduces new BPF extension. It makes possible to load
>> value of
>> skb->vlan_proto (vlan tpid) to register A.
>>
>> Currently, vlan header is removed from frame and information is
>> available to
>> userspace only via tpacket interface. Hence, it is not possible to
>> install
>> filter which uses value of vlan tpid field.
>>
>> AFAICT only way how to filter based on tpid value is to reconstruct
>> original
>> frame encapsulation and interpret BPF filter code in userspace. Doing
>> that is
>> way slower than doing filtering in kernel.
>>
>> Cc: Alexei Starovoitov <ast@plumgrid.com>
>> Cc: Jiri Pirko <jpirko@redhat.com>
>> Signed-off-by: Michal Sekletar <msekleta@redhat.com>
>> ---
>> @@ -282,6 +282,7 @@ Possible BPF extensions are shown in the following
>> table:
>>     vlan_tci                              skb_vlan_tag_get(skb)
>>     vlan_pr                               skb_vlan_tag_present(skb)
>>     rand                                  prandom_u32()
>> +  vlan_proto                            skb->vlan_proto
> 
> the patch is correct and looks clean, but I don't understand
> the motivation for the patch.
> There is already SKF_AD_VLAN_TAG_PRESENT. If it is set then only
> two possible values of vlan_proto are ETH_P_8021Q or ETH_P_8021AD.
> If there another vlan header inside the packet, it's AD.

802.1ad can be used without an inner vlan tag.
Also, we can send/receive QinQ frames with 802.1Q outer tags.
(We can create vlan interface on 802.1Q vlan interface.)

Thanks,
Toshiaki Makita
