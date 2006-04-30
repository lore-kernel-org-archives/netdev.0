From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: IP1000 gigabit nic driver
Date: Sun, 30 Apr 2006 12:26:11 +0300
Message-ID: <1146389171.11524.1.camel@localhost>
References: <20060427142939.GA31473@fargo>
	 <20060427185627.GA30871@electric-eye.fr.zoreil.com>
	 <445144FF.4070703@cantab.net> <20060428075725.GA18957@fargo>
	 <84144f020604280358ie9990c7h399f4a5588e575f8@mail.gmail.com>
	 <20060428113755.GA7419@fargo>
	 <Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI>
	 <1146306567.1642.3.camel@localhost>  <20060429122119.GA22160@fargo>
	 <1146342905.11271.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Vrabel <dvrabel@cantab.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:26240 "EHLO
	mail.cs.helsinki.fi") by vger.kernel.org with ESMTP
	id S1751075AbWD3J0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 05:26:24 -0400
To: "David =?ISO-8859-1?Q?G=F3mez?=" <david@pleyades.net>
In-Reply-To: <1146342905.11271.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-04-29 at 14:21 +0200, David G=F3mez wrote:
> > I already had it modified, just needed to create the patch... Anywa=
y,
> > have you submitted it to netdev?

On Sat, 2006-04-29 at 23:35 +0300, Pekka Enberg wrote:
> No, I haven't. I don't have the hardware, so I can't test the driver.
> Furthermore, there's plenty of stuff to fix before it's in any shape =
for
> submission. If someone wants to give this patch a spin, I would love =
to
> hear the results.

I killed the I/O write/read macros and switched the driver to iomap.

			Pekka

Subject: [PATCH] IP1000 Gigabit Ethernet device driver

This is a cleaned up fork of the IP1000A device driver:

  <http://www.icplus.com.tw/driver-pp-IP1000A.html>

Open issues include but are not limited to:

  - ipg_probe() looks really fishy and doesn't handle all errors
    (e.g. ioremap failing).
  - ipg_nic_do_ioctl() is playing games with user-space pointer.
    We should use ethtool ioctl instead as suggested by Arjan.
  - For multiple devices, the driver uses a global root_dev and
    ipg_remove() play some tricks which look fishy.

I don't have the hardware, so I don't know if I broke anything.
The patch is 138 KB in size, so I am not including it in this
mail. You can find the patch here:

  http://www.cs.helsinki.fi/u/penberg/linux/ip1000-driver.patch

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>

