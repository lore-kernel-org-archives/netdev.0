From: Ben Chan <benchan@chromium.org>
Subject: Re: How to replace control code in gdm72xx?
Date: Wed, 16 Jul 2014 17:59:15 -0700
Message-ID: <CAC5Y2nNfiZ_cdiitj07KsB_DbGTgO=PMUwHGaXwrXjQ-U1bLyA@mail.gmail.com>
References: <53C6DF7C.8030109@fastmail.fm> <20140716204004.GA31349@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, inaky@linux.intel.com
To: Greg KH <greg@kroah.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140716204004.GA31349@kroah.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 16, 2014 at 1:40 PM, Greg KH <greg@kroah.com> wrote:
>
> On Wed, Jul 16, 2014 at 09:24:28PM +0100, Michalis Pappas wrote:
> > Hi,
> >
> > I'm currently working on bringing the gdm72xx WiMAX driver out of
> > staging. The driver currently uses two control channels:
> >
> > 1. The SIOCDEVPRIVATE ioctl to send and receive state messages
> >
> > 2. A customly defined netlink protocol for passing messages verbatim to
> > the device controller
> >
> > AFAIK both of the above are deprecated, so I considered switching to
> > the interface defined in wimax.h, which defines a communication protocol
> > over generic netlink that replaces (2) nicely. However it is not
> > compatible with (1), as:
> >
> > * Except from the device status, the gdm72xx driver uses two more types
> > of messages (connection and OMA status), which is not supported
> > by wimax.h.
> >
> > * The gdm driver needs to be able to receive status messages from
> > userspace, which is not supported by wimax.h either.
>
> What type of status messages are needed to be sent to the driver?
>

>From what I read from the user-space code, the custom ioctl is to read
the following information from the driver:

enum {
    SIOC_DATA_FSM,           // Device/Connection State
    SIOC_DATA_NETLIST,       // Network list
    SIOC_DATA_CONNNSP,     // Connected NSP
    SIOC_DATA_CONNCOMP,    // Connection completion info
    SIOC_DATA_PROFILEID,    // WiMAX profile ID
    SIOC_DATA_END
};

Reference:

https://chromium.googlesource.com/chromiumos/third_party/gdmwimax/+/master/sdk/io.c
https://chromium.googlesource.com/chromiumos/third_party/gdmwimax/+/master/sdk/sdk.c
https://chromium.googlesource.com/chromiumos/third_party/gdmwimax/+/master/sdk/wm_ioctl.h


>
> > I therefore consider using the wimax stack as defined in wimax.h for the
> > netlink part, but replacing the ioctl with a file under /sys/class/net/wm0/
>
> Is anyone still working on wimax to even object to add new functions
> like this?  :)
>

The driver has a corresponding user-space library, so I'd like to
figure out a way to maintain backward compatibility if possible. But
I'm happy to help make minor changes to  the user-space library in
case we need to modify the ioctl / netlink part of the driver (caveat:
I'm not the author of the driver or the user-space library).

> thanks,
>
> greg k-h
> _______________________________________________
> devel mailing list
> devel@linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
