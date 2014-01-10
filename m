From: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH V2 0/4] misc: xgene: Add support for APM X-Gene SoC Queue
 Manager/Traffic Manager
Date: Fri, 10 Jan 2014 14:40:16 -0800
Message-ID: <CAN1v_PuySRzi6r9aT_SJrQRMBh9gj-5yXOOY1QpyZ6V4wXyZCA@mail.gmail.com>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
	<1441245.xPZLG2iNZ6@wuerfel>
	<CAN1v_PtFz42crHW5=cUgw-fAnPn3rQht=o0t3nmjJRamYSLDMg@mail.gmail.com>
	<201401051911.12349.arnd@arndb.de>
	<CAN1v_PsaAeDiLaiP7FfTHFbNRG=UHuom6-2L6NMwzyOOyB+5cA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Loc Ho <lho-qTEPVZfXA3Y@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Jon Masters <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"patches-qTEPVZfXA3Y@public.gmane.org" <patches-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAN1v_PsaAeDiLaiP7FfTHFbNRG=UHuom6-2L6NMwzyOOyB+5cA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 5, 2014 at 12:48 PM, Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org> wrote:
> On Sun, Jan 5, 2014 at 10:11 AM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
>> On Sunday 05 January 2014, Ravi Patel wrote:
>>> On Sat, Dec 21, 2013 at 11:03 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
>>> >
>>> > Please describe here what the purpose of the qmtm is, as this is not
>>> > entirely clear from the code or from your reply.
>>> >
>>> > Greg was guessing that it's a bus controller, my best guess is a DMA
>>> > engine. If it's something completely different, you have to let
>>> > us know what it is so we can do a proper review rather than guessing.
>>> >
>>> > Please provide a link to the data sheet if you are unable to explain.
>>>
>>> Here is URL to a text document explaining role of QMTM device with CPU, Ethernet
>>> subsystem.
>>>
>>> https://drive.google.com/file/d/0B28TgQZ3JLoRRGNnbjJoUGNHWW8/edit?usp=sharing
>>>
>>> For simplicity, I have shown only Ethernet.
>>> PktDMA and Security subsystem interfaces with QMTM in the same way as Ethernet.
>>
>> Thanks, that helps a lot. Please add this file to an appropriate place
>> in the Documentation directory in the next version of your patches.
>>
>> There is still one central aspect that remains unclear to me, which is
>> what the QMTM is actually good for, as opposed to how it gets used from
>> the OS.
>
> The document shows the run-time flow of messages between CPU, QMTM and Ethernet.
> QMTM is a centralized resource manager/driver which exports APIs to
> 1. Initialize & allocate queue & pbn to the Ethernet, PktDMA and
> Security subsystem.
> 2. Read queue state so that subsystems driver knows how much more work
> it can offload
>     to its subsystem.
> 3. Apply QoS for subsystems on their queues.
>
>> In the text description, it sounds like the ethernet is the DMA
>> master and performs DMA all by itself but from that it's not clear why
>> a message to and from the QMTM is needed. From your drawing on the other
>> hand, it seems like the QMTM is really the DMA master and performs the
>> DMA on behalf of the ethernet device, which isn't connected to the
>> coherent interface itself. If this is correct, it seems that QMTM is more
>> like a DMA engine after all that should use the existing slave API to
>> provide services to slave drivers.
>
> Each subsystem defines their own format of work message.
> A message (or queue descriptor) has attribute fields (QMTM specific)
> which is common
>  for all subsystem work messages.
> The remaining fields of a message are specific to subsystem.
> QMTM device doesn't have any knowledge of these subsystem specific
> fields and the data
> operation which subsystem is going to perform using these fields.
> e.g.
> 1. Ethernet work message includes data address & length which is used
> by Ethernet
> DMA engine for copying the data to/from its internal FIFO
> 2. PktDMA work message includes multiple data addresses & lengths for
> doing scatter/gather,
> XOR operations and result data address/es to give back result to the
> CPU (driver)
> 3. Security work message includes data address & length for doing
> encryption or decryption,
> the type of encryption or decryption and result data address to give
> back result to the CPU (driver)

Do you want any further clarification or document related to QMTM.
We want to make sure everyone is on same page, understand and
conclude upon that QMTM is a device and and not a bus or a dma
engine.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
