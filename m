From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Wed, 04 Mar 2015 23:23:25 -0800
Message-ID: <54F8046D.6070807@plumgrid.com>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com> <6E5AAA23-4000-4C29-BB4E-AA7C05B6F619@alum.mit.edu> <54F7997A.3020604@plumgrid.com> <20150305065053.GA2062@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guy Harris <guy@alum.mit.edu>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:44102 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397AbbCEHXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 02:23:23 -0500
Received: by igdh15 with SMTP id h15so43598215igd.3
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 23:23:22 -0800 (PST)
In-Reply-To: <20150305065053.GA2062@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/15 10:50 PM, Jiri Pirko wrote:
> Thu, Mar 05, 2015 at 12:47:06AM CET, ast@plumgrid.com wrote:
>> On 3/4/15 1:14 PM, Guy Harris wrote:
>>>
>>> On Mar 4, 2015, at 1:03 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>>
>>>> the patch is correct and looks clean, but I don't understand
>>>> the motivation for the patch.
>>>> There is already SKF_AD_VLAN_TAG_PRESENT. If it is set then only
>>>> two possible values of vlan_proto are ETH_P_8021Q or ETH_P_8021AD.
>>>> If there another vlan header inside the packet, it's AD.
>>>> So you can do the filtering already without adding new bpf extension...
>>>
>>> I presume he's referring to
>>>
>>> 	https://github.com/the-tcpdump-group/libpcap/issues/397
>>>
>>> or
>>>
>>> 	https://github.com/the-tcpdump-group/libpcap/issues/390
>>
>> ok. context is clear.
>> yet, it still sounds like something to fix inside libpcap.
>
> Libpcap need to somehow let kernel now what vlan proto it should filter on.

I don't think that's what bug report talking about. It's looking to
match on vlan id regardless of vlan_proto. Only vlan_tag_present is
needed to make it work.

> Also, it is not true that another vlan header inside packet is AD. You
> can have packet with just AD header (or 2 AD or 2 Q, etc).

yes. Correct, but then again it doesn't seem to be the goal of the bug 
report.
To make myself clear. I think the patch is ok, I'm only asking for
clear justification based on real use case and not invented one.
