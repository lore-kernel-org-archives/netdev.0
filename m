From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Port STP state after removing port from bridge
Date: Wed, 18 Feb 2015 20:39:55 -0800
Message-ID: <CAGVrzcZMV3vSd3hEsXqk6BtyU-Ts9=oJvb79DTZp25TnnGm5CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:45676 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbbBSEkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 23:40:36 -0500
Received: by iecat20 with SMTP id at20so6749241iec.12
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 20:40:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It just occured to me that the following sequence:

brctl addbr br0
brctl addif br0 port0
... STP happens
brctl delif br0 port0

will leave port0 in STP disabled state, because the bridge code will
set the STP state to DISABLED, and only a down/up sequence can bring
it back to FORWARDING.

Is this something that we should somehow fix? As an user it seems a
little convoluted having to do a down/up sequence to restore things. I
believe however that it is valid for the bridge layer to mark a port
as DISABLED when removing it. This is typically not noticed or even
remotely a problem with software bridges because we cannot enforce an
actual STP state at the HW level.

Let me know your thoughts.
-- 
Florian
