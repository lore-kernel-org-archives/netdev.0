From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: 4.4.1 skb_warn_bad_offload+0xc5/0x110
Date: Wed, 24 Feb 2016 23:20:29 +0100
Message-ID: <56CE2CAD.1020008@stressinduktion.org>
References: <20160216000838.GA12968@animx.eu.org>
 <56CB0CF5.1060906@stressinduktion.org> <20160224010137.GA27602@animx.eu.org>
 <20160224014652.GA15207@animx.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wakko Warner <wakko@animx.eu.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160224014652.GA15207@animx.eu.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24.02.2016 02:46, Wakko Warner wrote:
> Please keep me in CC.
>
> Wakko Warner wrote:
>>
>> Hannes Frederic Sowa wrote:
>>> [full-quote for netdev]
>>>
>>> Hello,
>>>
>>> On 16.02.2016 01:08, Wakko Warner wrote:
>>>> I've been seeing the following on some of my VMs ran under qemu.  The VMs do
>>>> not have internet connectivity.  This happened when some files were accessed
>>>> via NFS to another VM (NOTE: Both VMs throw these warnings.  Both VMs are
>>>> running the exact same kernel).  The host is also throwing these warnings
>>>> and is also 4.4.1, but not the same kernel build.
>>>>
>>>> The issue appears to have gone away if I issue the following on the guests
>>>> and on the host (except br0 instead of eth0 on host)
>>>> ethtool -K eth0 gso off gro off ufo off tso off
>>>>
>>>> On the host, br0 does not have any interfaces enslaved except for the
>>>> interface for the VMs and also does not have an IPv4 address assigned.
>>>>
>>
>>> Can you try the following patch?
>>>
>>> --- a/net/ipv4/ip_output.c
>>> +++ b/net/ipv4/ip_output.c
>>> @@ -1233,6 +1233,9 @@ ssize_t   ip_append_page(struct sock *sk,
>>> struct flowi4 *fl4, struct page *page,
>>>          if (!skb)
>>>                  return -EINVAL;
>>>
>>> +       if (skb->ip_summed != CHECKSUM_PARTIAL)
>>> +               return -EINVAL;
>>> +
>>>          cork->length += size;
>>>          if ((size + skb->len > mtu) &&
>>>              (sk->sk_protocol == IPPROTO_UDP) &&
>>
>> Still received the warning.  I saw it on the host and on one of the VMs.
>> The VM in this case was an nfs server.  The client did not receive the
>> warning.  I should mention that I'm using v3 and udp on the client for the
>> mount options.
>>
>> I'm not sure if this change effected nfsd on one of the VMs, it isn't working
>> at all on it.
>
> I reverted back to the previous kernel for the VM only and the nfsd on the
> one VM started working.
>
> I should note that when I added this change, I only compiled the kernel and
> copied the bzImage file.  I did not recompile any modules nor copy the
> system.map over.

Actually, I could reproduce it locally thus I pushed a slightly 
different patch already. You have to patch all VMs in terms to not get 
the warning in the hypervisor anymore.

Bye,
Hannes
