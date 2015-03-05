From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Wed, 04 Mar 2015 23:49:32 -0800
Message-ID: <54F80A8C.2040009@plumgrid.com>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com> <6E5AAA23-4000-4C29-BB4E-AA7C05B6F619@alum.mit.edu> <54F7997A.3020604@plumgrid.com> <20150305065053.GA2062@nanopsycho.orion> <20150305072413.GB25656@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guy Harris <guy@alum.mit.edu>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>, Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:42149 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754357AbbCEHt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 02:49:29 -0500
Received: by iecvy18 with SMTP id vy18so10232597iec.9
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 23:49:29 -0800 (PST)
In-Reply-To: <20150305072413.GB25656@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/15 11:24 PM, Michal Kubecek wrote:
> On Thu, Mar 05, 2015 at 07:50:53AM +0100, Jiri Pirko wrote:
>> Thu, Mar 05, 2015 at 12:47:06AM CET, ast@plumgrid.com wrote:
>>> On 3/4/15 1:14 PM, Guy Harris wrote:
>>>>
>>>> On Mar 4, 2015, at 1:03 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>>>
>>>>> the patch is correct and looks clean, but I don't understand
>>>>> the motivation for the patch.
>>>>> There is already SKF_AD_VLAN_TAG_PRESENT. If it is set then only
>>>>> two possible values of vlan_proto are ETH_P_8021Q or ETH_P_8021AD.
>>>>> If there another vlan header inside the packet, it's AD.
>>>>> So you can do the filtering already without adding new bpf extension...
>>>>
>>>> I presume he's referring to
>>>>
>>>> 	https://github.com/the-tcpdump-group/libpcap/issues/397
>>>>
>>>> or
>>>>
>>>> 	https://github.com/the-tcpdump-group/libpcap/issues/390
>>>
>>> ok. context is clear.
>>> yet, it still sounds like something to fix inside libpcap.
>>
>> Libpcap need to somehow let kernel now what vlan proto it should filter on.
>
> To be more precise, it does not need it now as there is no syntax for
> pcap filter on TPID, one can only filter by VID. But if someone wanted
> to implement such feature, it could not work with in-kernel filtering at
> the moment.

exactly my point. That's how we should evaluate the patch.
It does provide extra visibility for classic bpf programs and
it's not strongly required at the moment, but can be useful, no doubt.
At the same time it forever exposes skb->vlan_proto to user space,
so any refactoring of sk_buff would need to deal with that.
With the use case presented I don't have strong opinion one way or
the other.
