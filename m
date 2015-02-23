From: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Subject: Re: [PATCH v2 0/3] net: Linn Ethernet Packet Sniffer driver
Date: Mon, 23 Feb 2015 09:37:24 +0000
Message-ID: <54EAF4D4.4090505@linn.co.uk>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk> <20150218210830.GA7778@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150218210830.GA7778-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On 18/02/15 21:08, Richard Cochran wrote:
> On Tue, Feb 17, 2015 at 02:03:30PM +0000, Stathis Voukelatos wrote:
>> The command string for packet matching is stored in module RAM
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
>
> Why do you need to expose this interface to user space at all?  Why
> not just time stamp every frame?

To put this into context with an example, the use case this H/W module 
was originally developed for was to allow multiple audio receivers to 
synchronize with a single transmitter, eg. multi-room synchronised audio.
The interface needs to be public so that a user-space application can 
program a command string that will match packets that belong to the 
audio stream of interest, for this example.
In addition returning just a timestamp would not be enough in many 
cases. In the audio streaming use case mentioned above some additional
bytes from the packet payload need to be returned (with Copy commands) 
in order to associate the timestamp with a certain point in the audio 
stream.

>
> How does the "Match" command work?  The frame must have one particular
> byte?  That can't be right.  Please explain.

Actually, that is how the H/W works. Each Match command is followed by
a data value which must match the packet data byte at the corresponding
location. If there is no match processing of the packet stops.

>
> Thanks,
> Richard
>

Thank you,
Stathis
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
