From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 2/3] can: add support for Janz VMOD-ICAN3 Intelligent
	CAN	module
Date: Fri, 19 Mar 2010 21:13:37 +0100
Message-ID: <4BA3DAF1.4090206@grandegger.com>
References: <> <1268930324-29841-3-git-send-email-iws@ovro.caltech.edu>
	<4BA33D5A.8070000@grandegger.com>
	<20100319151914.GB13672@ovro.caltech.edu>
	<4BA39C05.8050800@grandegger.com>
	<20100319200325.GE13672@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100319200325.GE13672-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Ira W. Snyder wrote:
> On Fri, Mar 19, 2010 at 04:45:09PM +0100, Wolfgang Grandegger wrote:
>> Ira W. Snyder wrote:
>>> On Fri, Mar 19, 2010 at 10:01:14AM +0100, Wolfgang Grandegger wrote:
>>>> Hi Ira,
>>>>
>>>> we already discussed this patch on the SocketCAN mailing list and there
>>>> are just a few minor issues and the request to add support for the new
>>>> "berr-reporting" option, if feasible. See:
>>>>
>>>>   commit 52c793f24054f5dc30d228e37e0e19cc8313f086
>>>>   Author: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>>>>   Date:   Mon Feb 22 22:21:17 2010 +0000
>>>>
>>>>     can: netlink support for bus-error reporting and counters
>>>>     
>>>>     This patch makes the bus-error reporting configurable and allows to
>>>>     retrieve the CAN TX and RX bus error counters via netlink interface.
>>>>     I have added support for the SJA1000. The TX and RX bus error counters
>>>>     are also copied to the data fields 6..7 of error messages when state
>>>>     changes are reported.
>>>>
>>>> Should not be a big deal.
>>>>
>>> I think this patch came along since my last post of the driver. I must
>>> have missed it. I'll try and add support.
>> No problem, it's really new. Just just need to enable BEI depending on
>> CAN_CTRLMODE_BERR_REPORTING.
>>
> 
> I have one final question about this.
> 
> The documentation for the firmware isn't very specific here. I believe
> that in order to get any kind of error messages, I need the bus error
> feature turned on. What is the expected behavior of an SJA1000 with the
> BEI (bus error interrupt) turned off? Will you still get warning
> messages for ERROR_ACTIVE -> ERROR_PASSIVE state transitions?

Yes. State transitions are enabled with EI and EPI.

> I'm not sure how I would go about testing this feature, either. Ideas?

Send messages without cable connected and watch the error messages with
"candump any,0:0,#ffffffff". With "ip ... berr-reporting on" you should
see additional bus-errors.

> I also noticed that I can enable "self test mode" and "listen only mode"
> using the same firmware command. It appears that there are netlink
> messages for this as well. Should I try and support these, too? I don't
> really have any use for them (yet). I assume "self test mode" is
> equivalent to "loopback mode" in the netlink messages.

List-only is straight forward while "self test mode" is not exactly like
"loopback mode", IIRC. Feel free to send a follow-up patch when you have
time for a thorough implementation and testing. It's also on my to-do
list for the SJA1000.

Wolfgang.

> 
> Thanks,
> Ira
> 
> 
