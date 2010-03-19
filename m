From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [PATCH 2/3] can: add support for Janz VMOD-ICAN3 Intelligent
 CAN	module
Date: Fri, 19 Mar 2010 14:52:27 -0700
Message-ID: <20100319215227.GF13672@ovro.caltech.edu>
References: <>
 <1268930324-29841-3-git-send-email-iws@ovro.caltech.edu>
 <4BA33D5A.8070000@grandegger.com>
 <20100319151914.GB13672@ovro.caltech.edu>
 <4BA39C05.8050800@grandegger.com>
 <20100319200325.GE13672@ovro.caltech.edu>
 <4BA3DAF1.4090206@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, sameo@linux.intel.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BA3DAF1.4090206@grandegger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 19, 2010 at 09:13:37PM +0100, Wolfgang Grandegger wrote:
> Ira W. Snyder wrote:
> > On Fri, Mar 19, 2010 at 04:45:09PM +0100, Wolfgang Grandegger wrote:
> >> Ira W. Snyder wrote:
> >>> On Fri, Mar 19, 2010 at 10:01:14AM +0100, Wolfgang Grandegger wrote:
> >>>> Hi Ira,
> >>>>
> >>>> we already discussed this patch on the SocketCAN mailing list and there
> >>>> are just a few minor issues and the request to add support for the new
> >>>> "berr-reporting" option, if feasible. See:
> >>>>
> >>>>   commit 52c793f24054f5dc30d228e37e0e19cc8313f086
> >>>>   Author: Wolfgang Grandegger <wg@grandegger.com>
> >>>>   Date:   Mon Feb 22 22:21:17 2010 +0000
> >>>>
> >>>>     can: netlink support for bus-error reporting and counters
> >>>>     
> >>>>     This patch makes the bus-error reporting configurable and allows to
> >>>>     retrieve the CAN TX and RX bus error counters via netlink interface.
> >>>>     I have added support for the SJA1000. The TX and RX bus error counters
> >>>>     are also copied to the data fields 6..7 of error messages when state
> >>>>     changes are reported.
> >>>>
> >>>> Should not be a big deal.
> >>>>
> >>> I think this patch came along since my last post of the driver. I must
> >>> have missed it. I'll try and add support.
> >> No problem, it's really new. Just just need to enable BEI depending on
> >> CAN_CTRLMODE_BERR_REPORTING.
> >>
> > 
> > I have one final question about this.
> > 
> > The documentation for the firmware isn't very specific here. I believe
> > that in order to get any kind of error messages, I need the bus error
> > feature turned on. What is the expected behavior of an SJA1000 with the
> > BEI (bus error interrupt) turned off? Will you still get warning
> > messages for ERROR_ACTIVE -> ERROR_PASSIVE state transitions?
> 
> Yes. State transitions are enabled with EI and EPI.
> 

I cannot set the registers directly, but I think I got it right. See
below.

> > I'm not sure how I would go about testing this feature, either. Ideas?
> 
> Send messages without cable connected and watch the error messages with
> "candump any,0:0,#ffffffff". With "ip ... berr-reporting on" you should
> see additional bus-errors.
> 

Ok, I tried this. On one controller, I turned on bus-error reporting. On
the other, I turn off bus-error reporting. I then tried sending lots of
messages with the cable unplugged. Here is what happened:

bus-error reporting on:
Lots of CAN_ERR_BUSERR messages are flooded in candump. There is also a
CAN_ERR_CRTL_TX_WARNING message, when there are too many TX errors.

bus-error reporting off:
There was only one message reported before the controller went into
ERROR-WARNING state. It was the same CAN_ERR_CRTL_TX_WARNING message as
above. There was no flooding of CAN_ERR_BUSERR messages.

Does this seem right? It seems pretty good to me.

> > I also noticed that I can enable "self test mode" and "listen only mode"
> > using the same firmware command. It appears that there are netlink
> > messages for this as well. Should I try and support these, too? I don't
> > really have any use for them (yet). I assume "self test mode" is
> > equivalent to "loopback mode" in the netlink messages.
> 
> List-only is straight forward while "self test mode" is not exactly like
> "loopback mode", IIRC. Feel free to send a follow-up patch when you have
> time for a thorough implementation and testing. It's also on my to-do
> list for the SJA1000.
> 

Ok, then I'll put this off for a while. Feel free to pester me about it
when there is a working implementation in the SJA1000 driver for me to
borrow from. :)

Thanks for all the help.
Ira
