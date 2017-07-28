From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Fri, 28 Jul 2017 18:43:42 +0200
Message-ID: <c1bf54ee-8634-23a1-abda-55bc3fafe2a8@sigmadesigns.com>
References: <823b1540-b528-bbd7-7f99-5dc39a08868a@sigmadesigns.com>
 <yw1xk22slemx.fsf@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        Mason <slash.tmp@free.fr>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:52323 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752115AbdG1Qns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 12:43:48 -0400
In-Reply-To: <yw1xk22slemx.fsf@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/2017 18:17, Måns Rullgård wrote:

> Marc Gonzalez wrote:
> 
>> ndo_stop breaks RX in a way that ndo_open is unable to undo.
> 
> Please elaborate.  Why can't it be fixed in a less heavy-handed way?

I'm not sure what "elaborate" means. After we've been through
ndo_stop once, the board can send packets, but it doesn't see
any replies from remote systems. RX is wedged.

I think ndo_stop is rare enough an event that doing a full
reset is not an issue, in terms of performance. Also I will
need this infrastructure anyway for suspend/resume support.

It might also make sense to put the HW in reset at close
(to save power). I will try measuring the power savings,
if any.


>> Work around the issue by resetting the HW in ndo_open.
>> This will provide the basis for suspend/resume support.
>>
>> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>> ---
>>  drivers/net/ethernet/aurora/nb8800.c | 40 +++++++++++++++++-------------------
>>  drivers/net/ethernet/aurora/nb8800.h |  1 +
>>  2 files changed, 20 insertions(+), 21 deletions(-)
> 
> I'm pretty sure this doesn't preserve everything it should.

Hmmm, we're supposed to start fresh ("full reset").
What could there be to preserve?
You mentioned flow control and multicast elsewhere.
I will take a closer look. Thanks for the heads up.

Regards.
