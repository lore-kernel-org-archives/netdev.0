From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 6/7] net: add the AF_FLEXRAY protocol
Date: Sun, 18 Aug 2013 20:50:40 +0200
Message-ID: <52111780.90006@hartkopp.net>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de> <1376384922-8519-8-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:48657 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab3HRSun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 14:50:43 -0400
In-Reply-To: <1376384922-8519-8-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.08.2013 11:08, Benedikt Spranger wrote:
> FlexRay is a networking technology used in automotive fields as
> successor of the Controller Area Network (CAN). It provides the
> core functionality and a RAW protocol driver.
>=20
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>

Hello Benedikt,

first thanks for picking this FlexRay topic together with Eberspaecher.

There was a first attempt getting FlexRay into mainline by Michael Arnd=
t:

http://www.scriptkiller.de/en/c27/computer_electronics/linux/flexray_4_=
linux/

You probably know that implementation too - it has a nice FlexRay Linux=
 Logo.
My comment on that former implementation was if AF_FLEXRAY is really ne=
eded or
if a PF_PACKET socket would make it too.

I think to have the local echo of frames and if you intend to add the F=
lexRay
specific transport protocol it would make sense to create an AF_FLEXRAY=
=2E

The ISO15765-2 implementation would be a good starting point then:
https://gitorious.org/linux-can/can-modules/blobs/master/net/can/isotp.=
c

Some general remarks to your patch series:

- please write FlexRay and not Flexray in the comments

- patch 4/7 creates

 include/linux/eray.h          |  650 +++++++++++++++++++++++++
 include/linux/flexcard.h      |   95 ++++
 include/uapi/linux/eray.h     |   34 ++
 include/uapi/linux/flexcard.h |  429 +++++++++++++++++

I wonder, if this header pollution is really needed on this level

E.g. eray.h could go into drivers/net/flexray/eray/eray.h ...

- It's not clear where flexcard begins and what is part of the Eray IP =
core.
  I would suggest to have a Eray core driver (like we have the SJA1000 =
at CAN)
  and create some Flexcard specific glue code to access the Eray core.
  E.g. there is surely other HW available that uses the Eray core, righ=
t?
  You have a clear separation from the Flexcard to the D_CAN controller=
 too.

- Why do you need a

>  include/uapi/linux/flexray/flexcard_netlink.h |  53 +++

???

Please try to find a generic approach that fits for all FlexRay hardwar=
e.

- some remarks on the file headers:

  - Better write Eberspaecher than Ebersp=C3=83=E2=82=ACcher which fits=
 their website :-)
  - there's no License information in the header
  - a reference that this code is based on the CAN code is appropriate

- struct can_frame cf -> struct flexray_frame ff (you should rename the=
 cf's)

I built your patches on the latest 3.11-rc5. Are there any simple tools=
 to
play with the vflexray created devices, like candump or cansend for CAN=
?

>  include/linux/flexray.h                       | 168 ++++++++

Looks good.

How are the FlexRay real-time requirements handled?
Is this done by the Eray core?

Best regards,
Oliver
