From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Wed, 6 Sep 2017 12:42:54 -0700
Message-ID: <49d6a93e-1966-5104-603d-aad2d9a9e8e9@gmail.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <a75691d9-c22a-9b89-2cce-604315062739@gmail.com>
 <d54d0555-c448-741c-eb63-5a773bed5a30@free.fr>
 <7b1c1dc9-b6e3-a1bd-2e36-474946741a79@gmail.com>
 <730292be-affa-c19d-75ab-edba367788e8@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        David Daney <ddaney.cavm@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:35048 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbdIFTnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 15:43:06 -0400
Received: by mail-wr0-f172.google.com with SMTP id y15so15648980wrc.2
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 12:43:05 -0700 (PDT)
In-Reply-To: <730292be-affa-c19d-75ab-edba367788e8@free.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2017 08:51 AM, Mason wrote:
> On 31/08/2017 21:18, Florian Fainelli wrote:
> 
>> On 08/31/2017 12:09 PM, Mason wrote:
>>
>>> On 31/08/2017 19:03, Florian Fainelli wrote:
>>>
>>>> On 08/31/2017 05:29 AM, Marc Gonzalez wrote:
>>>>
>>>>> On 31/08/2017 02:49, Florian Fainelli wrote:
>>>>>
>>>>>> The original motivation for this change originated from Marc Gonzalez
>>>>>> indicating that his network driver did not have its adjust_link
>>>>>> callback
>>>>>> executing with phydev->link = 0 while he was expecting it.
>>>>>
>>>>> I expect the core to call phy_adjust_link() for link changes.
>>>>> This used to work back in 3.4 and was broken somewhere along
>>>>> the way.
>>>>
>>>> If that was working correctly in 3.4 surely we can look at the diff and
>>>> figure out what changed, even maybe find the offending commit, can you
>>>> do that?
>>>
>>> Bisecting would a be a huge pain because my platform was
>>> not upstream until v4.4
>>
>> Then just diff the file and try to pinpoint which commit may have
>> changed that?
> 
> Running 'ip link set eth0 down' on the command-line.
> 
> In v3.4 => adjust_link() callback is called
> In v4.5 => adjust_link() callback is NOT called
> 
> $ git log --oneline --no-merges v3.4..v4.5 drivers/net/phy/phy.c | wc -l
> 59
> 
> I'm not sure what "just diff the file" entails.

git log -p --no-merges v3.4..v4.5 drivers/net/phy/{phy,phy_device.c} and
see what would seem remotely sensible to what you are observing.

> I can't move 3.4 up, nor move 4.5 down.

You can always copy the PHYLIB files at any given commit back into an
older tree, or vice versa because it is largely self contained with
little to no dependencies on other headers/files/facilities etc. This is
not convenient I agree, but it's a poor man's way of determining what
changed within PHYLIB that results in what you are seeing.

AFAICT you could use QEMU with the versatile board that has smsc911x as
an Ethernet adapter which is PHYLIB compliant which may be used to
pinpoint which commit start changing this behavior. It's long, it's painful.

> I'm not even sure the problem comes from drivers/net/phy/phy.c
> to be honest.

If that's the case then I am not sure what else we can do.
-- 
Florian
