From: David Brownell <david-b@pacbell.net>
Subject: Re: e100 "Ferguson" release
Date: Sun, 03 Aug 2003 21:08:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2DDC3A.2040707@pacbell.net>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>	<3F2CA65F.8060105@pobox.com>	<3F2CBA71.2070503@candelatech.com>	<20030803003239.4257ef24.davem@redhat.com>	<3F2DCE56.6030601@pacbell.net>	<20030803200851.7d46a605.davem@redhat.com>	<3F2DD6BD.7070504@pacbell.net> <20030803204642.684c6075.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, jgarzik@pobox.com, scott.feldman@intel.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030803204642.684c6075.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Sun, 03 Aug 2003 20:45:01 -0700
> David Brownell <david-b@pacbell.net> wrote:
> 
> 
>>What can't be pre-allocated in a reliable way is the resources
>>used by the host controller drivers, specifically the transfer
>>descriptors.  EHCI and OHCI usually need one per URB, unless
>>MTU is over 4 KB.  UHCI normally needs quite a few.
> 
> 
> Ok, that's interesting.

All TDs get allocated in usb_submit_urb(), which is the first
time the "real" core of USB connects an urb with an I/O queue.
That's host-side, not device-side.

> Is there a callback that tells the USB driver that some host
> controller "resources" have become available?  I mean, these host
> controllers either have to queue requests when out of resources or
> provide a callback so that the drivers can resubmit.

No such callback.  If no resources, they fail -ENOMEM and the
caller must recover.  Which is why hard_start_xmit() needs to
do something.

- Dave
