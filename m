From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Sat, 21 Feb 2015 16:50:02 +0100
Message-ID: <20150221155002.GA2092@nanopsycho.orion>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
 <54E76EFA.1050209@cumulusnetworks.com>
 <54E7876A.3060303@gmail.com>
 <20150221110359.GA2095@nanopsycho.orion>
 <FFEDCF9956066D4D97C463CC178C7F69F23378@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>
To: Viswanath Bandaru <vbandaru@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:39821 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbbBUPuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 10:50:06 -0500
Received: by wesx3 with SMTP id x3so10613781wes.6
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 07:50:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <FFEDCF9956066D4D97C463CC178C7F69F23378@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 21, 2015 at 12:29:38PM CET, vbandaru@broadcom.com wrote:
>> -----Original Message-----
>> >
>> >I agree, in fact, most of the HW I have access to only has a global age
>> >timer configuration knob. Is this configurable on a per-port basis for
>> >higher end switches, or even maybe per-FDB entry?
>> 
>> I'm currently not aware of any hw which does not have global age timer.
>> But I believe that they will appear. The model that we have now, to
>> propagate aging setting of bridge down is more general and should be ok.
>> 
>> Drivers should probably take care of multi bridge setup with different aging
>> setup. Maybe to find minimal time and print a warning?
>> 
>
>Setting up the minimal time in such a scenario is good. 
>
>Should we also consider the possibility bridges containing ports from different  devices (and therefore different drivers) ? If that is a possibility, I think the bridge module should take responsibility of finding out the minimal time to pushing to all involved drivers.

It is certainly possible to bridge ports from multiple switch devices.
But that should not be a problem, because 1 bridge has 1 aging setup
which will be passed to all port drivers.

I believe that the only case which need to be resolved is multiple
bridges over single switch device. And I believe that it should be
handled in drivers because only drivers know what the hw is capable of
(if it supports aging setup per port/bridge/global).

>
>
