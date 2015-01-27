From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Tue, 27 Jan 2015 10:51:09 +0000
Message-ID: <54C76D9D.8070704@linn.co.uk>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk> <54C6BFEA.5020101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <abrestic@chromium.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Stathis Voukelatos <stathisv70@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54C6BFEA.5020101@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On 26/01/15 22:30, Florian Fainelli wrote:
> On 23/01/15 02:07, Stathis Voukelatos wrote:
>> This patch adds support the Ethernet Packet Sniffer H/W module
>> developed by Linn Products Ltd and found in the IMG Pistachio SoC.
>> The module allows Ethernet packets to be parsed, matched against
>> a user-defined pattern and timestamped. It sits between a 100M
>> Ethernet MAC and PHY and is completely passive with respect to
>> Ethernet frames.
> Is there any latency penalty involved in capturing (or not) packets as
> opposed to having this capture HW unused?

There is no additional latency introduced by the sniffer at the H/W level,
if that is what you mean. Only the S/W overhead for handling the
sniffer interrupt for each match event.

>> Matched packet bytes and timestamp values are returned through a
>> FIFO. Timestamps are provided to the module through an externally
>> generated Gray-encoded counter.
>>
>> The command pattern for packet matching is stored in module RAM
>> and consists of a sequence of 16-bit entries. Each entry includes
>> an 8-bit command code and and 8-bit data value. Valid command
>> codes are:
>> 0 - Don't care
>> 1 - Match: packet data must match command string byte
>> 2 - Copy: packet data will be copied to FIFO
>> 3 - Match/Stamp: if packet data matches string byte, a timestamp
>>                   is copied into the FIFO
>> 4 - Copy/Done: packet data will be copied into the FIFO.
>>                 This command terminates the command string.
>>
>> The driver consists of two modules:
>> - Core: it provides an API to user space using the Generic Netlink
>>          framework. Specific backend implementations, like the
>>          Ethernet Packet Sniffer, register one or more channels
>>          with the Core. For each channel a Genl family is created.
>>          User space can access a channel by sending Genl messages
>>          to the Genl family associated with the channel. Packet
>>          matching events are multicast.
> Instead of having this new generic netlink family to control sniffing,
> could we imagine registering a netdevice which does not nothing but
> still allows for tools like tcpdump, af_packet and other capture tools
> to work transparently and just leverage the HW capture?
Thanks, I will work on that change. It has been suggested by a previous
reviewer too and it makes sense to go down that route.

Stathis
