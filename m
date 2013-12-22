From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/4] misc: xgene: Add base driver for APM X-Gene SoC
 Queue Manager/Traffic Manager
Date: Sat, 21 Dec 2013 17:01:29 -0800
Message-ID: <20131222010129.GA16366@kroah.com>
References: <1387507503-7565-1-git-send-email-rapatel@apm.com>
 <1387507503-7565-3-git-send-email-rapatel@apm.com>
 <20131220032133.GB32310@kroah.com>
 <CAN1v_PuBZHN85xTodfSZ-+H4Wdj0T8kSFUJB56KVj9xFH3--JQ@mail.gmail.com>
 <20131220042426.GA21726@kroah.com>
 <CAN1v_Pv-RRTW7cr5xNgAMySQrZi9zMxNjJfnKPi8fa3GUhGpNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jcm@redhat.com, "patches@apm.com" <patches@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Ravi Patel <rapatel@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAN1v_Pv-RRTW7cr5xNgAMySQrZi9zMxNjJfnKPi8fa3GUhGpNg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 21, 2013 at 04:43:06PM -0800, Ravi Patel wrote:
> > On Thu, Dec 19, 2013 at 07:41:13PM -0800, Ravi Patel wrote:
> >> There is no need to talk to this driver from userspace.
> >> It is a device which is used by other IO devices to communicate with each
> >> other, including CPU.
> >> For example, if CPU (software) wants to send a message to Ethernet HW (i.e.
> >> send packet),
> >> it used this driver to enqueue a message to Ethernet.
> >> In other direction, if Ethernet HW receives a packet, it uses QM/TM device to
> >> send message to
> >> CPU (software) to process packet.
> >
> > So it's a "bus" type of thing, right?
> >
> > My question of "why isn't this reflected in the driver model" still
> > stands.
> 
> There is no subsystem underneath QMTM, nor QMTM does any enumeration.
> QMTM is a centralized resource manager which manages queues circularly
> for Ethernet, PktDMA (XOR Engine) and Security Engine subsystems.
> Traffic Management feature of QMTM does flow control, QoS for the subsystems.
> Because of this reasons, its not obvious that QMTM can fit as a bus.
> However we are doing further evalution on this.

Just because you can't enumerate a device, doesn't mean it isn't a
"bus".  You say so yourself that this is how devices talk to the
hardware, so that sounds like a "bus" to me...

greg k-h
