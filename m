From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ss: Fix support for device filter by index
Date: Fri, 15 Jul 2016 12:56:55 -0600
Message-ID: <8fe8c4a4-6635-da65-0371-0c27239ce047@cumulusnetworks.com>
References: <1468600168-731-1-git-send-email-dsa@cumulusnetworks.com>
 <20160715115324.4993f886@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34852 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbcGOS46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:56:58 -0400
Received: by mail-pf0-f182.google.com with SMTP id c2so43962080pfa.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 11:56:58 -0700 (PDT)
In-Reply-To: <20160715115324.4993f886@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/15/16 12:53 PM, Stephen Hemminger wrote:
> On Fri, 15 Jul 2016 09:29:28 -0700
> David Ahern <dsa@cumulusnetworks.com> wrote:
>
>> Support was recently added for device filters. The intent was to allow
>> the device to be specified by name or index, and using the if%u format
>> (dev == if5) or the simpler and more intuitive index alone (dev == 5).
>> The latter case is broken since the index is not saved to the filter
>> after the strtoul conversion. Further, the tmp variable used for the
>> conversion shadows another variable used in the function. Fix both.
>>
>> With this change all 3 variants work as expected:
>> $ ss -t 'dev == 62'
>> State   Recv-Q Send-Q         Local Address:Port    Peer Address:Port
>> ESTAB       0      224         10.0.1.3%mgmt:ssh   192.168.0.50:58442
>>
>> $ ss -t 'dev == mgmt'
>> State   Recv-Q Send-Q         Local Address:Port    Peer Address:Port
>> ESTAB       0      224         10.0.1.3%mgmt:ssh   192.168.0.50:58442
>>
>> $ ss -t 'dev == if62'
>> State   Recv-Q Send-Q         Local Address:Port    Peer Address:Port
>> ESTAB       0      36          10.0.1.3%mgmt:ssh   192.168.0.50:58442
>>
>> Fixes: 2d2932125616 ("ss: Add support to filter on device")
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> Won't apply to current code.
> Please rebase.
>

It applies cleanly for me to master branch. That's where the ss dev 
filter is from June:

commit 2d29321256168e13e10fbde3c57f33e70dcb6cc8
Author: David Ahern <dsa@cumulusnetworks.com>
Date:   Mon Jun 27 11:34:25 2016 -0700

     ss: Add support to filter on device

No commits on that file since except 
62000e51e05d635016bae9891a4e00134ed8aefb which does not impact the 
function in question.
