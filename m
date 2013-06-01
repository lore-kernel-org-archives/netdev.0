From: Jesse Gross <jesse@nicira.com>
Subject: Re: RFC - VXLAN port range facility
Date: Sat, 1 Jun 2013 15:39:12 +0900
Message-ID: <CAEP_g=_Kb6_iVwxwBvGzg+RkcE7JRuO2hGxc4pcSELVfn7qWFw@mail.gmail.com>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>
 <20130530094141.7c125947@nehalam.linuxnetplumber.net> <OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com>
 <CAEP_g=8MkoK3DLJNGCrQYj_X9hB9P9fjH9hrpBwqOE=0OKWGdg@mail.gmail.com> <OF9DE1CF50.DAF9EEF0-ON85257B7C.0043CE0A-85257B7C.0044520B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:51997 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755880Ab3FAGjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 02:39:33 -0400
Received: by mail-ie0-f171.google.com with SMTP id s9so6129663iec.2
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 23:39:32 -0700 (PDT)
In-Reply-To: <OF9DE1CF50.DAF9EEF0-ON85257B7C.0043CE0A-85257B7C.0044520B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 31, 2013 at 9:26 PM, David Stevens <dlstevens@us.ibm.com> wrote:
> Jesse Gross <jesse@nicira.com> wrote on 05/31/2013 02:09:34 AM:
>
>> On Fri, May 31, 2013 at 3:00 AM, David Stevens <dlstevens@us.ibm.com>
> wrote:
>> > But I don't think there's particular advantage in splitting it up
> 30,000
>> > ways when 10 ways would be both practical, for binding, and spread
>> > traffic to 10 flows potentially.
>>
>> Most people that run large data centers think that 16 bits of entropy
>> is barely sufficient. The issue is not CPUs or link aggregation but
>> Clos fabrics built using ECMP.
>>
>
> And most people running embedded systems wouldn't want to bind to
> 30,000 sockets by default, which is the proper way for VXLAN to
> interact with UDP.
>
> A casual user of VXLAN between a couple of small machines on ordinary
> Ethernet generally won't require multiple ports at all.
>
> I think the default case should lean towards the low end, and the
> mechanisms are there to tune the high end.

This line of argument doesn't make a lot of sense because scalability
and ECMP are the two reason that VXLAN was introduced in the first
place. Without the entropy in the source port, it's basically the same
as GRE.

Your solution needs to work reasonably across the entire range of use
cases and based on your arguments, it clearly doesn't. This doesn't
mean that those use cases don't exist or aren't important, it means
that you need to find another solution.
