From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Tue, 27 Jan 2015 17:22:36 +0000
Message-ID: <54C7C95C.4000007@linn.co.uk>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk> <54C22E68.1080601@redhat.com> <54C60DB8.1060900@linn.co.uk> <54C612A5.2000208@redhat.com> <54C7736C.8090704@linn.co.uk> <54C7A4DD.7030109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"abrestic@chromium.org" <abrestic@chromium.org>,
	<f.fainelli@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54C7A4DD.7030109@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Daniel,

On 27/01/15 14:46, Daniel Borkmann wrote:
>> Just wanted to clarify some implementation details for your approach.
>> - The driver would need to create and register two net_device instances.
>> One for sniffing Ethernet TX packets and one for RX.
>
> Hm, I would represent the whole device as a single monitoring-only 
> netdev.
> I'm somehow still missing the big advantage of all this as compared to
> using packet sockets on the normal netdev? I couldn't parse that from 
> your
> commit message.

This H/W module was developed to allow accurate timestamping of selected
outgoing or incoming data packets. Timestamp values are provided by an
external implementation-dependent clock or timer that is of suitable
quality for the application.
Example: multiple audio receivers synchronizing their clocks to a
single transmitter, for synchronized playback.

The TX and RX blocks of the sniffer can be operated (eg. started, stopped,
configured) independently, that is why I believe two netdev instances would
be a better match to the H/W architecture.

>
>> - Would the control interface for the sniffer in that case need to be
>> through private socket ioctls (ie SIOCDEVPRIVATE + x ioctl ids)?
>
> Nope, please have a look at Documentation/networking/packet_mmap.txt.
>
>
Thanks for the link to the document. That is the way forward for retrieving
data from sniffer match events from user space very efficiently.

However, I am not sure about configuration, where we want to eg set the
command string, or query device attributes such as the size of the command
memory. That looks more suitable to an ioctl or a netlink message to me
and better use the packet socket just for data from sniffer match events.

Thanks,
Stathis
