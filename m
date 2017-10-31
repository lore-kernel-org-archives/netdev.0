From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC net-next 4/4] net: phy: Correctly process PHY_HALTED in phy_stop_machine()
Date: Tue, 31 Oct 2017 16:26:01 +0100
Message-ID: <CAMuHMdXM_=Zj9AKUMhXNbC=27_X0XCn=h+aYFW1Gq03mHOqYhQ@mail.gmail.com>
References: <20171025232124.14120-1-f.fainelli@gmail.com> <20171025232124.14120-5-f.fainelli@gmail.com>
 <CAMuHMdUHdEuhMRzGGpg4ev_3pJy6ahGh4YMJjvrgBJAKgJLa7A@mail.gmail.com> <2630f8f3-9c07-cfe4-6d03-d8e3a746556f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, opendmb@gmail.com,
        Mason <slash.tmp@free.fr>, David Daney <david.daney@cavium.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:55733 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751565AbdJaP0E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 11:26:04 -0400
Received: by mail-lf0-f65.google.com with SMTP id e143so7392143lfg.12
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 08:26:03 -0700 (PDT)
In-Reply-To: <2630f8f3-9c07-cfe4-6d03-d8e3a746556f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Mon, Oct 30, 2017 at 5:09 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 10/30/2017 06:56 AM, Geert Uytterhoeven wrote:
>> On Thu, Oct 26, 2017 at 1:21 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> Marc reported that he was not getting the PHY library adjust_link()
>>> callback function to run when calling phy_stop() + phy_disconnect()
>>> which does not indeed happen because we set the state machine to
>>> PHY_HALTED but we don't get to run it to process this state past that
>>> point.
>>>
>>> Fix this with a synchronous call to phy_state_machine() in order to have
>>> the state machine actually act on PHY_HALTED, set the PHY device's link
>>> down, turn the network device's carrier off and finally call the
>>> adjust_link() function.
>>>
>>> At the end of phy_state_machine() though, if we are going to be moving
>>> from PHY_HALTED to PHY_HALTED, do not reschedule the state machine, this
>>> is pointless.
>>>
>>> Reported-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>>> Fixes: a390d1f379cf ("phylib: convert state_queue work to delayed_work")
>>> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>
>> Thanks for your patch!
>>
>> Unfortunately, after applying this one, the last in your series, both
>> sh73a0/kzm9g and r8a73a4/ape6evm start crashing again in the system
>> suspend/resume path, due to register accesses while the device is already
>> suspended:
>
> OK, seems like there is another path, uncovered by this patch that we
> can be hitting, does the following patch below help?

Unfortunately it doesn't help.

>> Unhandled fault: imprecise external abort (0x1406) at 0x0005b950

Note that this is an imprecise external abort, i.e. it's reporting may
be delayed,
and the backtrace may be inaccurate.

Gr{oetje,eeting}s,

                        Geert
