From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 1/9] net: Remove martian_source_keep_err goto
 label
Date: Tue, 22 Sep 2015 18:39:16 -0700
Message-ID: <560202C4.3090108@gmail.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
 <1442962523-3974-2-git-send-email-dsa@cumulusnetworks.com>
 <5601FA87.2080701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35290 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805AbbIWBjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 21:39:18 -0400
Received: by pacfv12 with SMTP id fv12so25398142pac.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 18:39:18 -0700 (PDT)
In-Reply-To: <5601FA87.2080701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2015 06:04 PM, Alexander Duyck wrote:
> On 09/22/2015 03:55 PM, David Ahern wrote:
>> err is initialized to -EINVAL when it is declared. It is not reset until
>> fib_lookup which is well after the 3 users of the martian_source jump. So
>> resetting err to -EINVAL at martian_source label is not needed.
>>
>> Removing that line obviates the need for the martian_source_keep_err
>> label
>> so delete it.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> The comments above and the code below don't sync up.  The function
> fib_validate_source can return either -EINVAL, -EXDEV, 0, or 1.  The
> fact is this may be acceptable as long as all callers of
> ip_route_input_slow will handle a non-zero value as an error and it
> doesn't care about what the actual return value is.  If that is what you
> are going for here at least the comment should be updated, and we should
> be explicit somewhere about documenting the return values.

Actually this patch is correct.  I got my wires a bit crossed and 
misread martian_source vs martian_source_keep_err.
