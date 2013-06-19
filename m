From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Adding support for ARINC429 into the Linux kernel
Date: Wed, 19 Jun 2013 23:45:30 +0200
Message-ID: <201306192345.31106.arnd@arndb.de>
References: <20130619202954.GA5594@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130619202954.GA5594@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 June 2013, Guenter Roeck wrote:
> I have been asked to explore options for adding ARINC 429 support [1]
> into the Linux kernel, primarily to support devices from Holt Integrated
> Circuits [2] (the request is unrelated to the chip manufacturer).
> 
> ARINC429 is a protocol which is widely used in commercial airplanes. 
> 
> There are various chips supporting this protocol available, as well as
> out-of-tree Linux support. The drivers I have looked at implement it
> either as character device or misc device and typically pass raw receive
> data to userspace.
> 
> I can see a number of options for going forward:
> 1) Implement as character device (or possibly misc device) and pass
>    raw data to/from user space
>    1a) Just implement a driver for the specific chips
>    2b) Implement some kind of generic infrastructure
> 2) Implement as network driver with a new address family, similar to,
>    say, AF_CAN.
> 
> Any thoughts / suggestions which approach would be better and, most of all,
> which approach might have a better chance of being accepted upstream ?

Since this is a standard protocol, a driver that just supports a specific
chip (1a) would be the worst option IMHO.

A character device and a network protocol both sound reasonable, but
it really depends on the use cases:

* Does Linux act both as the sender and receiver, or do you want to
  support just one of the cases (which?)?

* Would you expect to always just transfer a single 32-bit word, or
  are there larger chunks of logically contigous data? What are typical
  and maximum sizes for those?

* Would you expect the kernel to filter for specific data on the
  receiver side?

* Would a user space receiver want to always see all data from one
  sender, or only the latest word?

	Arnd
