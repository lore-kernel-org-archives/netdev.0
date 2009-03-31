From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2 V2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 18:01:19 -0500
Message-ID: <49D2A0BF.2090901@lwfinger.net>
References: <49d264dd.YwbXLw18YaD1tQqD%Larry.Finger@lwfinger.net> <200903312350.38658.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764218AbZCaXCb@vger.kernel.org>
In-Reply-To: <200903312350.38658.oliver@neukum.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> Am Dienstag 31 M=E4rz 2009 20:45:49 schrieb Larry Finger:
>> On an SMP system, the following message is printed. The patch below =
gets
>> fixes the problem.
>=20
> Are you sure it is never called with disabled interrupts?

I think not, but all I really know is that the change from spin_lock() =
to
spin_lock_irq() makes the errors go away.

I checked a number of drivers to see what their ndo_start_xmit routines=
 do. Most
use spin_lock_irq(), but some do no locking.

I tried removing the locking, but that resulted in a stall even when I =
bypassed
the faulty router.

Larry
