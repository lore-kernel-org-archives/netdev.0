From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 1/2 2.6] e100: fix NAPI race with watchdog
Date: Thu, 23 Sep 2004 10:08:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095930528.415292a0cd16a@www.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jesse.brandeburg@intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> While polling in NAPI mode, we were occassionally getting interrupts
> re-enabled by the watchdog trying to generate a software interrupt.
> Fix is to add a spinlock around that shared hardware register to
> allow a read-modify-write operation.  This was nasty nasty.  I don't
> like the spinlock in the hot path but i see no other way.  Comments
> are welcome.

While working with NAPI on the e100 a while ago, I seriously
considered removing the generation of the sw interrupt altogether for
the NAPI case. Does it serve any purpose? NAPI is polling the driver
already anyway.

/james
