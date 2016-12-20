From: Brian Norris <briannorris@chromium.org>
Subject: Re: [PATCH v2 2/3] Bluetooth: btusb: Add out-of-band wakeup support
Date: Mon, 19 Dec 2016 19:41:23 -0800
Message-ID: <20161220034122.GA40060@google.com>
References: <1481916604-114279-1-git-send-email-rajatja@google.com>
 <1481916604-114279-2-git-send-email-rajatja@google.com>
 <20161219231021.GA142074@google.com>
 <CACK8Z6FteRYmrNq5Oq9LpHOUOYg49XrL0WsxD8G45pTw_cwaSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Amitkumar Karwar <akarwar@marvell.com>,
        Wei-Ning Huang <wnhuang@chromium.org>,
        Xinming Hu <huxm@marvell.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        linux-kernel@vger.kernel.org, Rajat Jain <rajatxjain@gmail.com>
To: Rajat Jain <rajatja@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACK8Z6FteRYmrNq5Oq9LpHOUOYg49XrL0WsxD8G45pTw_cwaSg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 05:46:19PM -0800, Rajat Jain wrote:
> On Mon, Dec 19, 2016 at 3:10 PM, Brian Norris <briannorris@chromium.org> wrote:
> > On Fri, Dec 16, 2016 at 11:30:03AM -0800, Rajat Jain wrote:
> >> diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
> >> index ce22cef..beca4e9 100644
> >> --- a/drivers/bluetooth/btusb.c
> >> +++ b/drivers/bluetooth/btusb.c

> >> +static const struct of_device_id btusb_match_table[] = {
> >> +     { .compatible = "usb1286,204e" },
> >> +     { }
> >> +};
> >> +MODULE_DEVICE_TABLE(of, btusb_match_table);
> >
> > You define a match table here, but you also define essentially same
> > table for Marvell-specific additions in patch 3. It looks like maybe
> > it's legal to have more than one OF table in a module? But it seems like
> > it would get confusing, besides being somewhat strange to maintain. It
> > might also produce duplicate 'modinfo' output.
> >
> > If you really want to independently opt into device-tree-specified
> > interrupts vs. Marvell-specific interrrupt configuration, then you
> > should probably just merge the latter into the former table, and
> > implement a Marvell/GPIO flag to stick in the .data field of this table.
> 
> The data we want to stick (The pin number on the chip) is board
> specific rather than being chip specific, and hence .data may not be
> useful here.

I just meant that if you conceptually wanted Marvell devices to "opt in"
to this, then you could turn the .data field into some kind of flag or
struct for describing capabilities (e.g., MARVELL_GPIO_WAKE or similar),
effectively merging the two tables instead of having two
mostly-overlapping tables.

But you could do the same by putting such flag(s) in the
{btusb,blacklist}_table[], or add such flag(s) later whenever there's a
Marvell device that doesn't support this feature.

> > Or it might be fine to drop one or both "match" checks. Particularly for
> > the Marvell-specific stuff, it's probably fair just to check if it has
> > an ->of_node and if 'id->driver_info & BTUSB_MARVELL'. Any other Marvell
> > device-specific quirks could probably be keyed off of the
> > (weirdly-named?) blacklist_table[], which already matches PID/VID.
> 
> Yup, I think I can remove the compatible string checks.
> 
> I'll be sending a V3.

Great!

Brian
