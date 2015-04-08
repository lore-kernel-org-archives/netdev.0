From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: e1000e max frame calculation
Date: Wed, 08 Apr 2015 10:17:27 -0700
Message-ID: <552562A7.8090307@gmail.com>
References: <5522B685.2030104@cchtml.com> <5522FE84.6030104@cchtml.com> <55231425.4010405@redhat.com> <alpine.NEB.2.11.1504062043320.2726@chris.i8u.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Michael Cronenworth <mike@cchtml.com>, netdev@vger.kernel.org
To: Hisashi T Fujinaka <htodd@twofifty.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36176 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbbDHRR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 13:17:29 -0400
Received: by pabsx10 with SMTP id sx10so120754989pab.3
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 10:17:29 -0700 (PDT)
In-Reply-To: <alpine.NEB.2.11.1504062043320.2726@chris.i8u.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2015 08:47 PM, Hisashi T Fujinaka wrote:
> On Mon, 6 Apr 2015, Alexander Duyck wrote:
>
>> The e1000e pch parts seem very limited in terms of their jumbo frames
>> support.  It looks like the first pch part only supported 4K, and in
>> the case of the later generations I only see support for a 9018 jumbo
>> frame listed in the datasheet.  I suspect this is why that is set as
>> the limit in the driver. The question at this point is if 9018 is the
>> limit, why is it the limit and is there any wiggle room to it.
>
> It's a limit that was told to us by the HW group for the 82579.

The question I have is if the limit of 9018 includes the VLAN header or
not.  The reason why I ask is that prior to 3.15 you could configure an
MTU of 9000, and then still enable VLANs which would push the upper size
to a theoretical limit of 9022.

For example, what is the upper limit on the Windows driver for this
part?  Does it not support a jumbo frame size of 9014 (Excluding the CRC
and VLAN header)?  If so we could probably increase the value to 9022 in
these drivers, not suffer any ill effects, and resolve the issue that
Michael has been having after the change to include the VLAN_HLEN on the
max frame size calculation.

- Alex
