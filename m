From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Fix support for device filter by index
Date: Fri, 15 Jul 2016 11:53:24 -0700
Message-ID: <20160715115324.4993f886@xeon-e3>
References: <1468600168-731-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33976 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbcGOSxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:53:08 -0400
Received: by mail-pf0-f175.google.com with SMTP id p64so10047194pfb.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 11:53:07 -0700 (PDT)
In-Reply-To: <1468600168-731-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jul 2016 09:29:28 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Support was recently added for device filters. The intent was to allow
> the device to be specified by name or index, and using the if%u format
> (dev == if5) or the simpler and more intuitive index alone (dev == 5).
> The latter case is broken since the index is not saved to the filter
> after the strtoul conversion. Further, the tmp variable used for the
> conversion shadows another variable used in the function. Fix both.
> 
> With this change all 3 variants work as expected:
> $ ss -t 'dev == 62'
> State   Recv-Q Send-Q         Local Address:Port    Peer Address:Port
> ESTAB       0      224         10.0.1.3%mgmt:ssh   192.168.0.50:58442
> 
> $ ss -t 'dev == mgmt'
> State   Recv-Q Send-Q         Local Address:Port    Peer Address:Port
> ESTAB       0      224         10.0.1.3%mgmt:ssh   192.168.0.50:58442
> 
> $ ss -t 'dev == if62'
> State   Recv-Q Send-Q         Local Address:Port    Peer Address:Port
> ESTAB       0      36          10.0.1.3%mgmt:ssh   192.168.0.50:58442
> 
> Fixes: 2d2932125616 ("ss: Add support to filter on device")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Won't apply to current code.
Please rebase.
