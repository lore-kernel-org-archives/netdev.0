From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/4] net: mpls: Convert number of nexthops to u8
Date: Mon, 27 Mar 2017 08:43:05 -0600
Message-ID: <b370c097-d0ad-95c5-2687-264da22d37d6@cumulusnetworks.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
 <1490461408-9551-2-git-send-email-dsa@cumulusnetworks.com>
 <871stjmn0o.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        rshearma@brocade.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35471 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752607AbdC0On2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 10:43:28 -0400
Received: by mail-pg0-f44.google.com with SMTP id 81so27632612pgh.2
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 07:43:17 -0700 (PDT)
In-Reply-To: <871stjmn0o.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/26/17 9:11 PM, Eric W. Biederman wrote:
> I don't like this.  Byte writes don't exist on all architectures.
> 
> So while I think always writing to rtn_nhn_alive under the
> rtn_lock ensures that we don't have wrong values written
> it is quite subtle.  And I don't know how this will interact with other
> fields that you are introducing.
> 
> AKA this might be ok, but I expect this formulation of the code
> will easily bit-rot and break.

net/ has other use cases -- e.g., ipv6 tunneling has proto as a u8.

It unrealistic for a route to have 255 or more nexthops so the point of
this patch is to not waste 8 bytes tracking it - especially when
removing it gets routes with ipv4 and ipv6 via's into a cache line.

I can make the alive counter a u16 without increasing the size of the
struct. I'd prefer to leave it as an u8 to have a u8 hole for flags
should something be needed later.
