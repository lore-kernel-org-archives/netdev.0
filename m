From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC net-next 3/4] bridge: move write-heavy fdb members
 in their own cache line
Date: Tue, 31 Jan 2017 08:37:57 -0800
Message-ID: <20170131083757.17b9a2aa@xeon-e3>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
        <1485876718-18091-4-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34638 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbdAaQiK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 11:38:10 -0500
Received: by mail-pf0-f180.google.com with SMTP id e4so107752807pfg.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 08:38:05 -0800 (PST)
In-Reply-To: <1485876718-18091-4-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Jan 2017 16:31:57 +0100
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> Fdb's used and updated fields are written to on every packet forward and
> packet receive respectively. Thus if we are receiving packets from a
> particular fdb, they'll cause false-sharing with everyone who has looked
> it up (even if it didn't match, since mac/vid share cache line!). The
> "used" field is even worse since it is updated on every packet forward
> to that fdb, thus the standard config where X ports use a single gateway
> results in 100% fdb false-sharing. Note that this patch does not prevent
> the last scenario, but it makes it better for other bridge participants
> which are not using that fdb (and are only doing lookups over it).
> The point is with this move we make sure that only communicating parties
> get the false-sharing, in a later patch we'll show how to avoid that too.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---

What about making updated a per-cpu value?
