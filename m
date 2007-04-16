From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: 2.6.21rc7 e1000 media-detect oddness.
Date: Mon, 16 Apr 2007 13:12:47 -0700
Message-ID: <4807377b0704161312r5bda6275naa1c9085959c5713@mail.gmail.com>
References: <20070416034539.GC21217@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Dave Jones" <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:52101 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030942AbXDPUMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 16:12:48 -0400
Received: by nz-out-0506.google.com with SMTP id s1so1311057nze
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2007 13:12:48 -0700 (PDT)
In-Reply-To: <20070416034539.GC21217@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/15/07, Dave Jones <davej@redhat.com> wrote:
> I booted up 2.6.21rc7 without an ethernet cable plugged in,
> and noticed this..
>
> e1000: 0000:02:00.0: e1000_probe: The EEPROM Checksum Is Not Valid
> e1000: probe of 0000:02:00.0 failed with error -5
>
> I plugged a cable in, did rmmod e1000;modprobe e1000, and got this..
>
> e1000: 0000:02:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x1) 00:16:d3:3a:62:d3
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX
> e1000: eth0: e1000_watchdog: 10/100 speed: disabling TSO
>
> and it works fine..
> Why would no cable make it think the EEPROM is invalid ?
>
> I repeated this a few times, just to be sure it wasn't a fluke, and it
> seems to happen 100% reproducably.

This is a known issue, having to do with a power saving mode on the
PCIe side of the adapter, that is enabled when link is down.

There are several fixes, an eeprom fix, or changing the code to call
e1000_validate_eeprom_checksum twice in a row if the first fails.

this bug has some text about this and an attachment with the fix script
http://sourceforge.net/tracker/index.php?func=detail&aid=1474679&group_id=42302&atid=447449

Jesse
