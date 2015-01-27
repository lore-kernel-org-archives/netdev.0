From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Tue, 27 Jan 2015 15:46:53 +0100
Message-ID: <54C7A4DD.7030109@redhat.com>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk> <54C22E68.1080601@redhat.com> <54C60DB8.1060900@linn.co.uk> <54C612A5.2000208@redhat.com> <54C7736C.8090704@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"abrestic@chromium.org" <abrestic@chromium.org>,
	f.fainelli@gmail.com
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54C7736C.8090704@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stathis,

On 01/27/2015 12:15 PM, Stathis Voukelatos wrote:
> On 26/01/15 10:10, Daniel Borkmann wrote:
>>> Hello Daniel. Thank you for your feedback.
>>> Packet sockets could also be used for the driver interface to
>>> user space, however I think that both approaches would require the same
>>> amount of maintenance. We need to maintain a protocol consisting of
>>> a set of messages or commands that user space can use to communicate
>>> with the driver in order to configure the H/W and retrieve results.
>>> We could use packet sockets to send those messages  too, but I thought
>>> netlink already provides a message exchange framework that we could
>>> make use of.
>>
>> When using packet sockets and your driver as a backend feeding them,
>> users can see that there's an extra capturing/monitoring netdev present,
>> all libpcap-based tools such as tcpdump et al would work out of the box
>> w/o adapting any code, and as an admin you can also see what users/tools
>> are making of use of the device through packet sockets. I couldn't parse
>> the exact motivation from the commit message of why avoiding all this is
>> better?
>
> Just wanted to clarify some implementation details for your approach.
> - The driver would need to create and register two net_device instances.
> One for sniffing Ethernet TX packets and one for RX.

Hm, I would represent the whole device as a single monitoring-only netdev.
I'm somehow still missing the big advantage of all this as compared to
using packet sockets on the normal netdev? I couldn't parse that from your
commit message.

> - Would the control interface for the sniffer in that case need to be
> through private socket ioctls (ie SIOCDEVPRIVATE + x ioctl ids)?

Nope, please have a look at Documentation/networking/packet_mmap.txt.
