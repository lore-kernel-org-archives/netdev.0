From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: vrf: Fix dst reference counting
Date: Wed, 25 May 2016 11:02:55 -0600
Message-ID: <e0df6d2f-f3f3-9938-658a-58d97cb6ab09@cumulusnetworks.com>
References: <1464194131-3457-1-git-send-email-dsa@cumulusnetworks.com>
 <1464194131-3457-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:37079 "EHLO
	mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648AbcEYRIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 13:08:38 -0400
Received: by mail-it0-f47.google.com with SMTP id z123so32133207itg.0
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 10:08:37 -0700 (PDT)
In-Reply-To: <1464194131-3457-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I failed to update the auto-generated subject prefix in the patches. 
Both of these are for 4.5 stable not net-next.

On 5/25/16 10:35 AM, David Ahern wrote:
> commit 9ab179d83b4e31ea277a123492e419067c2f129a upstream
>
> Vivek reported a kernel exception deleting a VRF with an active
> connection through it. The root cause is that the socket has a cached
> reference to a dst that is destroyed. Converting the dst_destroy to
> dst_release and letting proper reference counting kick in does not
> work as the dst has a reference to the device which needs to be released
> as well.
>
> I talked to Hannes about this at netdev and he pointed out the ipv4 and
> ipv6 dst handling has dst_ifdown for just this scenario. Rather than
> continuing with the reinvented dst wheel in VRF just remove it and
> leverage the ipv4 and ipv6 versions.
>
> Fixes: 193125dbd8eb2 ("net: Introduce VRF device driver")
> Fixes: 35402e3136634 ("net: Add IPv6 support to VRF device")
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
