From: Mike Rapoport <mike@compulab.co.il>
Subject: Re: smsc911x suspend/resume
Date: Mon, 08 Feb 2010 17:10:16 +0200
Message-ID: <4B702958.5020806@compulab.co.il>
References: <4B6FDC83.9090205@compulab.co.il> <20100208101123.GW28972@buzzloop.caiaq.de> <4B6FF5E2.6060304@compulab.co.il> <20100208114638.GO9007@buzzloop.caiaq.de> <4B7022D1.5030408@compulab.co.il> <20100208144951.GF28972@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org,
	LAKML <linux-arm-kernel@lists.infradead.org>
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from compulab.co.il ([67.18.134.219]:34132 "EHLO compulab.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752499Ab0BHPLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 10:11:14 -0500
In-Reply-To: <20100208144951.GF28972@buzzloop.caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Mack wrote:
> On Mon, Feb 08, 2010 at 04:42:25PM +0200, Mike Rapoport wrote:
>> Daniel Mack wrote:
>>> In fact the datasheet doesn't really state that, and the chip seems
>>> to expect the power domains to remain switched on during suspend, and
>>> all power switching is done internally. Also the table in "7.4 Power
>>> Consumption (Device and System Components)" describes it like that.
>>>
>>> So it all comes down to the question of how low-power you need to be,
>>> and whether you need wake-on-lan or not. What's currently implemented is
>>> D1, but adding support for D2 should be easy.
>> I did some brute force save/restore of smsc9220 registers and it seems
>> to wake up now.
>> The question now is how to make it in a "generic" way ...
>> Thanks for the help anyway :)
> 
> Hmm, be careful about switching off power supplies that aren't supposed
> to be switched off while others are still powered. You can easily
> destroy hardware with that. Depending on how things are wired up
> internally, voltages can leak from one unit block to the other. Maybe
> Steve can can give a statement from official SMSC source about whether
> it is safe to switch off VDD33A in this case.
> 
> Anyway, from what's written in the datasheet, I wouldn't dare just
> blindly doing it.

I haven't dig too much in the datasheet, but I cannot remember anything
about keeping certain power supplies on during suspend. The only clue is
your comment in the driver that states
"/* This implementation assumes the devices remains powered on its VDDVARIO
  * pins during suspend. */"
And the platform I have either disables all supplies but VDDVARIO or keeps them
all up.
Anyway, I'll leave it running sleep/resume/ping cycle overnight to see in the
morning what have burned :)



> Daniel


-- 
Sincerely yours,
Mike.

