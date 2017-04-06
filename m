From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 00/13] ftgmac100: Rework batch 1 - Link & Interrupts
Date: Thu, 6 Apr 2017 12:46:30 -0700
Message-ID: <af8b8554-2788-cb48-9a13-d4d7f7085c3f@gmail.com>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
 <2344b1ea-f8bc-7491-4662-b8a3e94fb94e@gmail.com>
 <1491371595.4166.77.camel@kernel.crashing.org>
 <b59025eb-e653-8481-2e58-a780777df4ee@gmail.com>
 <1491373880.4166.79.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32920 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751881AbdDFTqc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:46:32 -0400
Received: by mail-io0-f196.google.com with SMTP id b140so534191iof.0
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 12:46:32 -0700 (PDT)
In-Reply-To: <1491373880.4166.79.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/04/2017 11:31 PM, Benjamin Herrenschmidt wrote:
> On Tue, 2017-04-04 at 23:02 -0700, Florian Fainelli wrote:
> 
>> We don't necessarily have a phydev attached when using NC-SI, so it was
>>> easier to have the core code path not have to go fishing for those
>>> settings in different places based on whether we're using NC-SI or not.
>>
>> Oh right, I missed that part. Is there a reason why NC-SI does not have
>> a PHY device attached? If not, could you somehow model the link using a
>> fixed PHY (which appears to Linux as a normal phy_device) just to keep
>> things simple.
> 
> Hrm ... maybe another day if you don't mind ;-)
> 
> First NC-SI isn't really a PHY .... it's a cross-over RMII connection
> to another NIC.
> 
> Now we could make it a phydev using a "fixed" PHY I suppose, that just
> "represents" the other end. That would be a way to do it. It would need
> to have the link permanently up however (see below).
> 
> That said I do want to tackle making it some kind of pseudo-PHY that
> actually reflects the state of the remote end (especially the link
> state, ie. up/down).
> 
> However there are a couple of issues to tackle if we do that. Well
> mostly one annoying one:
> 
> NC-SI needs to talk to the remote NIC via specific ethernet frames.
> 
> With the current link watch code however, if we reflect the remote link
> to the local NIC link via netif_carrier_on/off, we end up deactivating
> the device on link off and thus preventing the NC-SI stack from talking
> to the peer NIC at all.
> 
> I thought a while ago we could add some dev flag to prevent the link
> watch from doing that, but never got to look into it myself and
> apparently neither did Gavin.

It sounds like a similar situation to e.g: 802.1x, you want to let some
frames make it through and you need a working link for that, but you
can't quite flag the device as UP entirely. Maybe you can find a way to
re-use IFF_LOWER_UP to that purpose and only set that flag based on the
NC-SI frames indicating link state?
-- 
Florian
