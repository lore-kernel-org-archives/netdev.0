From: "Subhasish Ghosh" <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 4 May 2011 12:43:08 +0530
Message-ID: <15AD189F851849F69A011B6F4D1DDB6C@subhasishg>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<4DB5D452.9050500@grandegger.com>
	<46D523E49EFF489F9B088AE7B9CD7286@subhasishg>
	<201104271525.28512.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, m-watkins-l0cyMroinI0@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: "Arnd Bergmann" <arnd-r2nGTMty4D4@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201104271525.28512.arnd-r2nGTMty4D4@public.gmane.org>
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

> On Wednesday 27 April 2011, Subhasish Ghosh wrote:
>> >
>> > - Use just one value per sysfs file
>> 
>> SG - I felt adding entry for each mbx_id will clutter the sysfs.
>>         Is it ok to do that.
> 
> That is probably not much better either.
> 
> Note also that every sysfs file needs to come with associated
> documentation in Documentation/ABI/*/ to make sure that users
> will know exactly how the file is meant to work. 
> 
> Why do you need to export these values in the first place? Is
> it just for debugging or do you expect all CAN user space
> to look at this?
> 
> If it's for debugging, please don't export the files through sysfs.
> Depending on how useful the data is to regular users, you can
> still export it through a debugfs file in that case, which has
> much less strict rules.
> 
> If the file is instead meant as part of the regular operation of
> the device, it should not be in debugfs but probably be integrated
> into the CAN socket interface, so that users don't need to work
> with two different ways of getting to the device (socket and sysfs).
> 

CAN requires mail box IDs to be programmed in. But, the socket
CAN subsystem supports only software filtering of the mail box IDs.

So, the mail box IDs programmed into socket CAN during initialization
does not propagate into the hardware. This is planned to be a future
implementation in Socket CAN.

In our case, we support hardware filtering, to work around with this,
Wolfgang (Socket CAN owner) suggested that we implement
this using sysfs.

These setting are not for debugging, but to program the mail box IDs
into the hardware. 
