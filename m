From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/9] net: Refactor ip_route_input_slow
Date: Wed, 23 Sep 2015 08:03:00 -0600
Message-ID: <5602B114.3000009@cumulusnetworks.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
 <56023DDF.8000707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33331 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590AbbIWODE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 10:03:04 -0400
Received: by pacex6 with SMTP id ex6so41613248pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 07:03:04 -0700 (PDT)
In-Reply-To: <56023DDF.8000707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/15 11:51 PM, Alexander Duyck wrote:
>
> One option you might consider when untangling this is to just return the
> values instead of leaving any labels.  I just did a quick test on my
> system with gcc version 5.1.1 and going through and just replacing all
> of the labels with returns actually resulted in smaller code since the
> compiler was smart enough to just combine the returns anyway.

You have to unwrap it the way I did because there are a number of places 
with multiple jumps and a couple of places with fallthrough -- one label 
falling into the next.

>
> You may also want to increase the scope of this patch set to include
> __mkroute_input as it ends up being compiled into this function as
> well.  From what I have seen there is a bit of redundancy with some of
> the code from local_input.

Topic of another series. As is ip_route_input_mc. (and many other 
functions in this file)

Thanks for the review; new version coming soon.

David
