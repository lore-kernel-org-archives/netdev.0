From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] net: vrf: Add support for local traffic to
 local addresses
Date: Mon, 6 Jun 2016 17:01:44 -0600
Message-ID: <9ff023e5-5079-a5e1-b329-87987142bd97@cumulusnetworks.com>
References: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
 <20160606.151228.325662111382577833.davem@davemloft.net>
 <20160606.155643.1439926167947457716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34378 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbcFFXBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:01:42 -0400
Received: by mail-pa0-f48.google.com with SMTP id bz2so39522266pad.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 16:01:42 -0700 (PDT)
In-Reply-To: <20160606.155643.1439926167947457716.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/6/16 4:56 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 06 Jun 2016 15:12:28 -0700 (PDT)
>
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Thu,  2 Jun 2016 13:15:09 -0700
>>
>>> Add support for locally originated traffic to VRF-local addresses,
>>> be it addresses on enslaved devices or addresses on the VRF device:
>>  ...
>>
>> Series applied, but I've been wondering what happens to hw offloads
>> when these VRF devices sit in the middle.
>>
>> Does TSO et al. still occur properly?

It should, but I will double check and adjust if needed.

>
> Actually I have to revert this series, ip6_input() is not an exported
> module symbol.
>
> If you're only build testing things like this with everything "=y",
> please reconsider.
>

As I noted in the commit message "ip6_input is exported so the VRF 
driver can use it for the dst input function." It was dropped somewhere 
along the way of refactoring for upstream. Will send a v2.
