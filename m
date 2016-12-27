From: Robert Grasso <robert.grasso@modulonet.fr>
Subject: Re: driver r8169 suddenly failed
Date: Tue, 27 Dec 2016 20:41:45 +0100
Message-ID: <fd0ba97f-8730-4f71-9bd4-7a7552f673d2@modulonet.fr>
References: <428aa40c-e313-99ae-d3ae-97b6a5ef40e4@modulonet.fr>
 <20161227001248.GA20172@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
        netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.tech.numericable.fr ([82.216.111.38]:50716 "EHLO
        smtp2.tech.numericable.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933172AbcL0Tlw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 14:41:52 -0500
In-Reply-To: <20161227001248.GA20172@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have some unexpected (and interesting) news. I did not run the test 
yet. While I was investigating my issue, I ordered a fast 
Ethernet-to-USB3 converter, able to reach 1000Mbit/s, in order to 
recover my broadband quickly : here is the chip as reported by dmesg :

[    8.114327] ax88179_178a 4-1:1.0 eth2: register 'ax88179_178a' at 
usb-0000:03:00.0-1, ASIX AX88179 USB 3.0 Gigabit Ethernet, 00:0e:c6:c2:ce:d1

from the chinese brand  UGreen : at first sight, you do not seem to be 
related to it. On their advertisement, they allege they are compatible 
with kernel 2.6 and higher (which I confirmed on various forums before 
ordering it). However, guess what : I have the EXACT SAME behaviour !
- connected from the Shuttle (with USB3) on my cable modem, it fails to 
acquire the IP address as well (same endless loop) !
- from my laptop with Ubuntu 16.04 now : - connected on the LAN (and 
thus, on the Shuttle which runs my local DHCP server across YOUR 
perfectly functioning interface and driver) it works perfectly
                                          - connected on the cable 
modem, it fails too !

So, what is your opinion :
- should I broaden my request for help to other teams than yours (kernel 
maintainers) ?
- are you still interested in this test you asked for ?

Best regards

-- 
Robert Grasso
@home
---
UNIX was not designed to stop you from doing stupid things, because
   that would also stop you from doing clever things. -- Doug Gwyn

On 27/12/2016 01:12, Francois Romieu wrote:
> Robert Grasso <robert.grasso@modulonet.fr> :
> [dhcp snafu]
>> First of all, can you confirm that I am doing right in posting to you
>> (addresses found in README.Debian) ?
> It isn't completely wrong.
>
>> If I do, can you help ? I am not very proficient with Ethernet, and I am not
>> able to figure out what my provider changed : their hotline is
>> underqualified, they are just able to tell that "the signal on the line is
>> ok".
> You're spoiled. It is more than decent for a company whose core business
> used to sell cable TV.
>
>> But if you want me to run various tests, try new versions, I would be
>> glad to do so : I would appreciate if I could salvage this Shuttle.
> Please try a recent stable vanilla kernel and send a complete dmesg
> from boot. I need to identify the specific 816x chipset.
>
> Then record some traffic:
>
> # touch gonzo.pcap && tshark -w gonzo.pcap -i eth1
>
> It should only exhibit small outgoing packets but, well, one never knows.
>
> Check the leds activity to be sure that the network interfaces have not
> been renumbered.
>
> Use ethtool to check that tso is disabled. If it isn't, disable it.
>
