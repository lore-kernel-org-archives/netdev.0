From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 6 Dec 2012 14:40:03 -0800
Message-ID: <CAOxq_8PBoF7RqiPGoXCGyNHdGdNYfZ0ShOX_G6gMBNKOwnmArw@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com>
	<12918.1353190488@obiwan.sandelman.ca>
	<87obivu7n7.fsf@xmission.com>
	<CAOxq_8OC6zUm93mCHD5daxDmuYmmbUdgy0DnjfQdBKky_2t4nQ@mail.gmail.com>
	<87sj7iesdl.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Richardson <mcr@sandelman.ca>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:32958 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab2LFWkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 17:40:06 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so6541700vcd.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 14:40:05 -0800 (PST)
In-Reply-To: <87sj7iesdl.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 6, 2012 at 2:19 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Ani Sinha <ani@aristanetworks.com> writes:
>
>> On Sat, Nov 17, 2012 at 3:33 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>> the vlan header in packets as we receive them.
>>>
>>> The code is correct except for the case of packets in vlan 0.  Currently
>>> the packet reconstruction is ambiguous.  The most recent kernels have
>>> a TP_STATUS_VLAN_VALID flag that can be checked to see if the packet was
>>> in vlan 0 or if there was no vlan at all.  libpcap probably should be
>>> taught how to handle TP_STATUS_VLAN_VALID so that it can get the vlan 0
>>> handling correct.
>>>
>>
>> May be this?
>
> Two things.
>
> - TP_STATUS_VLAN_VALID lives in the tp_status field not the tp_vlan_tci field.
> - To work on older kernels with binaries compiled with newer headers you
>   first want to test for tp_vlan_tci == 0 and then look at the status field for
>   TP_STATUS_VALID.

yes you are right Eric on both counts. I will resend the patch again in a bit.

ani
