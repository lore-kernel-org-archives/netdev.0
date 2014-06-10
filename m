From: Florian Klink <flokli@flokli.de>
Subject: cdc-wdm: unable to connect after suspend
Date: Tue, 10 Jun 2014 12:20:02 +0200
Message-ID: <ln6m4k$q49$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040304020105080601080300"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:55433 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbaFJKZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 06:25:05 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1WuJEl-0007MG-Sy
	for netdev@vger.kernel.org; Tue, 10 Jun 2014 12:25:03 +0200
Received: from 82.113.99.253 ([82.113.99.253])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 12:25:03 +0200
Received: from flokli by 82.113.99.253 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 12:25:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040304020105080601080300
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

Hi,

I recently bought a notebook (Fujitsu Lifebook T904) with integrated
3G/4G modem (Sierra Wireless EM7305) thats powered by the cdc-wdm driver.

It works without any problems on a fresh bootup using Networkmanager.

However, after putting the notebook into standby and waking up again,
I'm unable to get a connection (always reproducible, not signal quality
related).

I see the following error messages:


Couldn't reload current power state: Transaction timed out
[/dev/cdc-wdm1] No transaction matched in received message
<warn> (cdc-wdm1) failed to connect modem: Transaction timed out
<info> (cdc-wdm1): device state change: prepare -> failed (reason
'unknown') [40 120 1]
modem_prepare_result: assertion 'state == NM_DEVICE_STATE_PREPARE' failed


It looks like a driver bug for me, like the device not woken up
correctly. I attached the syslog.

I'm running Arch Linux amd64 with an 3.15.0-rc8 kernel, and
NetworkManager 0.9.8.10.

Is there anybody else who observed this behaviour?

Florian

--------------040304020105080601080300
Content-Type: text/plain; charset=UTF-8;
 name="cdc-wdm_syslog.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="cdc-wdm_syslog.txt"

Jun 10 09:44:18 notebook NetworkManager[321]: <info> Activation (cdc-wdm1=
) starting connection 'FONIC Vorgabe'
Jun 10 09:44:18 notebook NetworkManager[321]: <info> (cdc-wdm1): device s=
tate change: disconnected -> prepare (reason 'none') [30 40 0]
Jun 10 09:44:18 notebook NetworkManager[321]: <info> Activation (cdc-wdm1=
) Stage 1 of 5 (Device Prepare) scheduled...
Jun 10 09:44:18 notebook NetworkManager[321]: <info> Activation (cdc-wdm1=
) Stage 1 of 5 (Device Prepare) started...
Jun 10 09:44:18 notebook NetworkManager[321]: <info> (cdc-wdm1): device s=
tate change: prepare -> need-auth (reason 'none') [40 60 0]
Jun 10 09:44:18 notebook NetworkManager[321]: <info> Activation (cdc-wdm1=
) Stage 1 of 5 (Device Prepare) complete.
Jun 10 09:44:18 notebook NetworkManager[321]: <info> Activation (cdc-wdm1=
) Stage 1 of 5 (Device Prepare) scheduled...
Jun 10 09:44:18 notebook NetworkManager[321]: <info> Activation (cdc-wdm1=
) Stage 1 of 5 (Device Prepare) started...
Jun 10 09:44:18 notebook NetworkManager[321]: <info> (cdc-wdm1): device s=
tate change: need-auth -> prepare (reason 'none') [60 40 0]
Jun 10 09:44:18 notebook NetworkManager[321]: <info> Activation (cdc-wdm1=
) Stage 1 of 5 (Device Prepare) complete.
Jun 10 09:44:18 notebook ModemManager[332]: <info>  Simple connect starte=
d...
Jun 10 09:44:18 notebook ModemManager[332]: <info>  Simple connect state =
(3/8): Enable
Jun 10 09:44:18 notebook ModemManager[332]: <info>  Modem /org/freedeskto=
p/ModemManager1/Modem/0: state changed (disabled -> enabling)
Jun 10 09:44:18 notebook NetworkManager[321]: <info> (cdc-wdm1) modem sta=
te changed, 'disabled' --> 'enabling' (reason: user-requested)
Jun 10 09:44:28 notebook ModemManager[332]: Couldn't reload current power=
 state: Transaction timed out
Jun 10 09:44:28 notebook ModemManager[332]: <info>  Modem /org/freedeskto=
p/ModemManager1/Modem/0: 3GPP Registration state changed (unknown -> sear=
ching)
Jun 10 09:44:51 notebook ModemManager[332]: [/dev/cdc-wdm1] No transactio=
n matched in received message
Jun 10 09:44:58 notebook ModemManager[332]: <info>  Modem /org/freedeskto=
p/ModemManager1/Modem/0: state changed (enabling -> disabled)
Jun 10 09:44:58 notebook NetworkManager[321]: <info> (cdc-wdm1) modem sta=
te changed, 'enabling' --> 'disabled' (reason: unknown)
Jun 10 09:44:58 notebook NetworkManager[321]: <warn> (cdc-wdm1) failed to=
 connect modem: Transaction timed out
Jun 10 09:44:58 notebook NetworkManager[321]: <info> (cdc-wdm1): device s=
tate change: prepare -> failed (reason 'unknown') [40 120 1]
Jun 10 09:44:58 notebook NetworkManager[321]: <warn> Activation (cdc-wdm1=
) failed for connection 'FONIC Vorgabe'
Jun 10 09:44:58 notebook NetworkManager[321]: <info> (cdc-wdm1): device s=
tate change: failed -> disconnected (reason 'none') [120 30 0]
Jun 10 09:44:58 notebook NetworkManager[321]: <info> (cdc-wdm1): deactiva=
ting device (reason 'none') [0]

--------------040304020105080601080300--
