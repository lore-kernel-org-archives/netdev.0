From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH RFC 1/3] ipv4: make flow functions more grepable by
 removing flowi4_init_output
Date: Wed, 15 Jun 2016 14:29:28 -0600
Message-ID: <2c081044-0861-8a84-f4ae-88c60c4ddc67@cumulusnetworks.com>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
 <1465850858-8559-2-git-send-email-hannes@stressinduktion.org>
 <6b8ad88f-db0b-3a88-197d-ed7278783bfc@cumulusnetworks.com>
 <20160615.124800.889153492414820174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org, ja@ssi.bg
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34306 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662AbcFOU3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 16:29:32 -0400
Received: by mail-pa0-f53.google.com with SMTP id bz2so10582584pad.1
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 13:29:32 -0700 (PDT)
In-Reply-To: <20160615.124800.889153492414820174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/15/16 1:48 PM, David Miller wrote:
> But if people don't use the helpers, and initialize flow structures
> on their own, yeah that defeats the whole mechanism and things will
> seem harder and "unhelpful".

That's my point -- the flow struct does not have a consistent 
initializer. There have been a number of bug patches over the past year 
like 4cfc86f3dae6 to handle uninitialized elements. My suggestion here 
is the same as 4cfc86f3dae6 which is to initialize the flow when it is 
declared.

Consider the recent change from Hannes for 38b7097b55b6. fl6 can be 
initialized when it is declared with a bit of straightforward 
refactoring -- icmp6_send has an easy split into 2.

Seems like that is a more robust long term solution considering the 
various init use cases.
