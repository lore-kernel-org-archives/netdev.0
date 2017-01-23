From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] vxlan: don't flush static fdb entries on
 admin down
Date: Mon, 23 Jan 2017 08:31:26 -0800
Message-ID: <58862FDE.6090008@cumulusnetworks.com>
References: <1484984599-16712-1-git-send-email-roopa@cumulusnetworks.com> <1484984599-16712-2-git-send-email-roopa@cumulusnetworks.com> <20170123095555.0778abb6@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        ramanb@cumulusnetworks.com, stephen@networkplumber.org,
        pshelar@ovn.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36538 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdAWQb3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:31:29 -0500
Received: by mail-pg0-f51.google.com with SMTP id t6so46191224pgt.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 08:31:28 -0800 (PST)
In-Reply-To: <20170123095555.0778abb6@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17, 12:55 AM, Jiri Benc wrote:
> On Fri, 20 Jan 2017 23:43:18 -0800, Roopa Prabhu wrote:
>> This patch skips flushing static fdb entries in
>> ndo_stop, but flushes all fdb entries during vxlan
>> device delete. This is consistent with the bridge
>> driver fdb
> This makes sense but isn't this a uAPI change? Do you know whether
> there are users relying on the current behavior?
>
yeah, i have debated about this also. I am sitting on a stash of such patches
which are borderline bug fixes but been out there long enough that people might care.

I leaned towards making it the default because,
- I am assuming not many people use static entries
- and people will not be very unhappy with this change....because it does not delete something
 they had...just retains them.
- Per device flag seems like an overkill here

Also, i think some such changes were done to the bridge driver too after it was out.
