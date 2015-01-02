From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v1 2/5] ixgbevf: Add a RETA query code
Date: Fri, 02 Jan 2015 19:49:19 +0200
Message-ID: <54A6DA1F.7040206@cloudius-systems.com>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com> <1420019519-18139-3-git-send-email-vladz@cloudius-systems.com> <54A439C4.8020004@gmail.com> <54A44188.204@cloudius-systems.com> <54A58D69.7080706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	"tantilov, Emil S" <emil.s.tantilov@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:64242 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbbABRtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 12:49:22 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so27984033wiw.14
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 09:49:21 -0800 (PST)
In-Reply-To: <54A58D69.7080706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 01/01/15 20:09, Alexander Duyck wrote:
> On 12/31/2014 10:33 AM, Vlad Zolotarov wrote:
>> On 12/31/14 20:00, Alexander Duyck wrote:
>>> I suspect this code is badly broken as it doesn't take several things
>>> into account.
>>>
>>> First the PF redirection table can have values outside of the range
>>> supported by the VF.  This is allowed as the VF can set how many bits of
>>> the redirection table it actually wants to use.  This is controlled via
>>> the PSRTYPE register.  So for example the PF can be running with 4
>>> queues, and the VF can run either in single queue or as just a pair of
>>> queues.
>>>
>>> Second you could compress this data much more tightly by taking
>>> advantage of the bit widths allowed.  So for everything x540 and older
>>> they only use a 4 bit value per entry.  That means you could
>>> theoretically stuff 8 entries per u32 instead of just 4.
>> Compression is nice but I think ethtool expects it in a certain
>> format: one entry per byte. And since this patch is targeting the
>> ethtool the output format should be as ethtool expects it to be and
>> this is what this patch does. However I agree that masking the
>> appropriate bits according to PSRTYPE is required. Good catch!
> The idea of compression comes into play when you consider there is
> significant latency trying to get messages across the mailbox.  By
> reducing the number of messages needed to get the redirection table you
> should be able to significantly reduce the amount of time needed to
> fetch it.  The job of compressing/expanding the values is actually
> pretty straight forward when you consider all that should be needed is a
> simple loop to perform some shift, and, and or operations.

We are talking about a super slow path here. So, regardless how slow it 
is it should be done only once between boots. Therefore IMHO any code 
complication is not justified here.

>
> - Alex
