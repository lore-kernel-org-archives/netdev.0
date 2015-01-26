From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Mon, 26 Jan 2015 11:10:45 +0100
Message-ID: <54C612A5.2000208@redhat.com>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk> <54C22E68.1080601@redhat.com> <54C60DB8.1060900@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stathis Voukelatos <stathisv70@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"abrestic@chromium.org" <abrestic@chromium.org>
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54C60DB8.1060900@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stathis,

On 01/26/2015 10:49 AM, Stathis Voukelatos wrote:
> On 23/01/15 11:20, Daniel Borkmann wrote:
>> On 01/23/2015 11:07 AM, Stathis Voukelatos wrote:
>>> This patch adds support the Ethernet Packet Sniffer H/W module
>>> developed by Linn Products Ltd and found in the IMG Pistachio SoC.
>>> The module allows Ethernet packets to be parsed, matched against
>>> a user-defined pattern and timestamped. It sits between a 100M
>>> Ethernet MAC and PHY and is completely passive with respect to
>>> Ethernet frames.
>>>
>>> Matched packet bytes and timestamp values are returned through a
>>> FIFO. Timestamps are provided to the module through an externally
>>> generated Gray-encoded counter.
>>>
>>> The command pattern for packet matching is stored in module RAM
>>> and consists of a sequence of 16-bit entries. Each entry includes
>>> an 8-bit command code and and 8-bit data value. Valid command
>>> codes are:
>>> 0 - Don't care
>>> 1 - Match: packet data must match command string byte
>>> 2 - Copy: packet data will be copied to FIFO
>>> 3 - Match/Stamp: if packet data matches string byte, a timestamp
>>>                    is copied into the FIFO
>>> 4 - Copy/Done: packet data will be copied into the FIFO.
>>>                  This command terminates the command string.
>>>
>>> The driver consists of two modules:
>>> - Core: it provides an API to user space using the Generic Netlink
>>>           framework. Specific backend implementations, like the
>>>           Ethernet Packet Sniffer, register one or more channels
>>>           with the Core. For each channel a Genl family is created.
>>>           User space can access a channel by sending Genl messages
>>>           to the Genl family associated with the channel. Packet
>>>           matching events are multicast.
>>>
>>> - Ethernet Packet Sniffer backend: provides the driver for the
>>>           Linn Ethernet Packet Sniffer H/W modules.
>>>
>>> The split between a core and backend modules allows software-only
>>> implementations to be added for platforms where no H/W support
>>> is available.
>>>
>>> Based on 3.19-rc5
>>>
>>> Signed-off-by: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
>> Please have a look at packet sockets, they offer already all the
>> functionality (if not more) your driver interface to the user space
>> resembles, are transparent to the underlying hardware, and easily
>> can cope with 100Mbit.
>>
>> If I understand this correctly, you are effectively introducing a
>> parallel API *next* to packet sockets to user space that we have to
>> maintain forever ...
>>
>> Thanks !
>
> Hello Daniel. Thank you for your feedback.
> Packet sockets could also be used for the driver interface to
> user space, however I think that both approaches would require the same
> amount of maintenance. We need to maintain a protocol consisting of
> a set of messages or commands that user space can use to communicate
> with the driver in order to configure the H/W and retrieve results.
> We could use packet sockets to send those messages  too, but I thought
> netlink already provides a message exchange framework that we could
> make use of.

When using packet sockets and your driver as a backend feeding them,
users can see that there's an extra capturing/monitoring netdev present,
all libpcap-based tools such as tcpdump et al would work out of the box
w/o adapting any code, and as an admin you can also see what users/tools
are making of use of the device through packet sockets. I couldn't parse
the exact motivation from the commit message of why avoiding all this is
better?

Thanks,
Daniel
