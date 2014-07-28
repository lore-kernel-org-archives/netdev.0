From: Dmitry Krivenok <krivenok.dmitry@gmail.com>
Subject: Question about 802.3ad bonding mode.
Date: Mon, 28 Jul 2014 18:59:36 +0400
Message-ID: <CAJN_NGY-u+rB1eBHV8XgdXPzwd2tQSmAf_=ZWFu2yob48siXzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: willy@meta-x.org, const-g@xpert.com, girouard@us.ibm.com,
	ctindel@ieee.org, mitch.a.williams@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:57321 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbaG1O7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 10:59:38 -0400
Received: by mail-lb0-f180.google.com with SMTP id v6so5969219lbi.11
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 07:59:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I have two physical NICs bonded into bond0 interface with bonding
mode=4 (i,e, 802.3ad).
Both NICs are connected to the same switch and switch ports are *not*
configured in "lacp" mode.

Documentation on this mode says this:

The 802.3ad mode requires that the switch have the appropriate
ports configured as an 802.3ad aggregation. The precise method used
to configure this varies from switch to switch, but, for example, a
Cisco 3550 series switch requires that the appropriate ports first be
grouped together in a single etherchannel instance, then that
etherchannel is set to mode "lacp" to enable 802.3ad (instead of
standard EtherChannel).

I'd expect that in such a case LAG should not be created via LACP. And
it's actually not created because I see the following LACPDUs coming
out of my NICs every 30 seconds:

13:27:25.968094 LACPv1, length: 110
        Actor Information TLV (0x01), length: 20
          System 00:60:16:56:ab:c1, System Priority 65535, Key 17,
Port 1, Port Priority 255
          State Flags [Activity, Aggregation, Synchronization, Default]
        Partner Information TLV (0x02), length: 20
          System 00:00:00:00:00:00, System Priority 65535, Key 1, Port
1, Port Priority 255
          State Flags [Activity]
        Collector Information TLV (0x03), length: 16
          Max Delay 0
        Terminator TLV (0x00), length: 0

AFAIK state flag "Default" means that we never got any LACPDUs from the switch.

I have IP address configured on bond0 and from what I see it's fully
working. I can ping it from various hosts, I can ssh to that host,
etc. From user perspective it works just fine except that there is no
LAG...

Is that correct behavior of dynamic link aggregation via LACP?
Shouldn't it be configuration error? Is it 802.1ax compliant?

Any help is very appreciated.

Thanks,
Dmitry

P.S.
My host is SLES11SP2, kernel 3.0.
