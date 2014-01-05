From: Ravi Patel <rapatel@apm.com>
Subject: Re: [PATCH V2 0/4] misc: xgene: Add support for APM X-Gene SoC Queue
 Manager/Traffic Manager
Date: Sat, 4 Jan 2014 21:27:30 -0800
Message-ID: <CAN1v_Pv7GoXqceu_vDpK-Rk3FzJKFjY=77JCw1fOOUOcuUHAjA@mail.gmail.com>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
	<201312212111.40576.arnd@arndb.de>
	<CAPw-ZTnsu_EmOW3aZTVKAVjQsdi8qMy95y2ZcYxzgVrjGkirTA@mail.gmail.com>
	<1441245.xPZLG2iNZ6@wuerfel>
	<CAN1v_PtFz42crHW5=cUgw-fAnPn3rQht=o0t3nmjJRamYSLDMg@mail.gmail.com>
	<20140105033848.GA22595@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arnd Bergmann <arnd@arndb.de>, Loc Ho <lho@apm.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Jon Masters <jcm@redhat.com>,
	"patches@apm.com" <patches@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140105033848.GA22595@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 4, 2014 at 7:38 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Sat, Jan 04, 2014 at 03:59:46PM -0800, Ravi Patel wrote:
>> On Sat, Dec 21, 2013 at 11:03 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> > On Saturday 21 December 2013 17:00:51 Loc Ho wrote:
>> >> On Sat, Dec 21, 2013 at 12:11 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> >> > On Saturday 21 December 2013, Ravi Patel wrote:
>> >> >> This patch adds support for APM X-Gene SoC Queue Manager/Traffic Manager.
>> >> >>  QMTM is required by APM X-Gene SoC Ethernet, PktDMA (XOR Engine) and
>> >> >>  Security Engine subsystems. All subsystems communicate with QMTM using
>> >> >>  messages which include information about the work to be performed and
>> >> >>  the location of associated data buffers.
>> >> >
>> >> > Please describe here what the purpose of the qmtm is, as this is not
>> >> > entirely clear from the code.
>> >> >
>> >> > In particular, please describe how this differs from a dmaengine driver
>> >> > and why it is not possible to extend the dma slave API to describe qmtm
>> >> > as a dma engine.
>> >> >
>> >> [Loc Ho]
>> >> If the QM driver implements the DMA API, what about the actual DMA
>> >> engine driver which interfaces with this QM driver. We would have DMA
>> >> client interfaces with the X-Gene DMA driver (not available yet) via
>> >> DMA API which in turn interfaces with this QM driver via DMA API.
>> >> Won't this be kind of awkward? Also, the QM only manage messages (or
>> >> descriptors) which are 32-bytes or 64-bytes. It doesn't actually do
>> >> any data transfer of various sizes.
>> >
>> > Please describe here what the purpose of the qmtm is, as this is not
>> > entirely clear from the code or from your reply.
>> >
>> > Greg was guessing that it's a bus controller, my best guess is a DMA
>> > engine. If it's something completely different, you have to let
>> > us know what it is so we can do a proper review rather than guessing.
>> >
>> > Please provide a link to the data sheet if you are unable to explain.
>>
>> Here is URL to a text document explaining role of QMTM device with CPU, Ethernet
>> subsystem.
>>
>> https://drive.google.com/file/d/0B28TgQZ3JLoRRGNnbjJoUGNHWW8/edit?usp=sharing
>
> There is nothing at this link :(

The URL is pointing to text document.
I created another URL to the same document in pdf format.
https://docs.google.com/file/d/0B28TgQZ3JLoRbXJiUXJjSUNxeDA/edit?usp=sharing&pli=1


>> PktDMA and Security subsystem interfaces with QMTM in the same way as Ethernet.
>
> How does a "security" subsystem have anything to do with ethernet?
>
> confused,

PktDMA and Security are completely independent of Ethernet.
Security Subsystem (SEC) is a CPU offload packet processing engine for security
 applications.
PktDMA subsystem is a general purpose data transfer engine which moves data
 from one location in memory to another.
PktDMA can perform certain data manipulation functions like XOR as
data is passing
 through the engine.
Both PktDMA and Security engine has their own QMTM work message format which
 will be prepared by their driver
