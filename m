From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: add device IDs for Dell 5804
 (Novatel E371) WWAN card
Date: Wed, 08 May 2013 14:25:50 -0500
Message-ID: <1368041150.1664.22.camel@dcbw.foobar.com>
References: <87li7r6bx1.fsf@nemi.mork.no>
	 <20130508.120850.755474428060131481.davem@davemloft.net>
	 <CAO2Qn5myQRhscszx0WRX588EP5NzPZuOsr1mrH3p4yDna8YP-w@mail.gmail.com>
	 <20130508.121922.553557463648781118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dagofthedofg@gmail.com, bjorn@mork.no, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130508.121922.553557463648781118.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-08 at 12:19 -0700, David Miller wrote:
> From: dag dg <dagofthedofg@gmail.com>
> Date: Wed, 8 May 2013 14:11:48 -0500
> 
> > Just a side note on this. By default for this device, modprobe won't
> > load and assign the option driver. However, if cdc_ether is
> > blacklisted and you try to load option onto the device, it will try to
> > load the option driver onto where cdc_ether was being used, which will
> > cause the system to lock up. I'm not sure what needs to be done to
> > force qmi_wwan to take over cdc_ether without option grabbing these
> > IDs...

This is a consequence of "new_id" not being flexible enough to handle
class/subclass/protocol in addition to USB IDs.  Thus when you use it,
the driver binds to *all* USB interfaces, even ones that the driver
shouldn't ever control

So the issue you refer to is actually user error, helped by a
too-coarse-grained kernel API.  It's not an issue when things are all
done correctly, which is to say when the USB IDs and interface
class/subclass/protocol are properly added to the kernel drivers.

The option patch I posted earlier will fix this issue correctly.

Dan
