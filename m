From: "Sasha V. Alexandr" <s.alexandr@hush.com>
Subject: 2.6.29 forcedeth: NIC always asleep/borked at reboot. Boot hangs@DHCP-Discover
Date: Fri, 03 Apr 2009 19:39:27 +0000
Message-ID: <20090403193927.81A6928058@smtp.hushmail.com>
Reply-To: s.alexandr@hush.com
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: s.alexandr@hush.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp12.hushmail.com ([65.39.178.135]:38466 "EHLO
	smtp12.hushmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759434AbZDCUMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 16:12:15 -0400
Received: from smtp12.hushmail.com (localhost.localdomain [127.0.0.1])
	by smtp12.hushmail.com (Postfix) with SMTP id ACB12700E8
	for <netdev@vger.kernel.org>; Fri,  3 Apr 2009 19:39:28 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi netdev folks,

I have been following the several threads regarding forcedeth since
the release of 2.6.29 and mainly they are focused on NAPI-troubles-
or-not, and WOL not working. I think what I am experiencing since
2.6.29 is directly related to neither WOL nor NAPI, but is a
forcedeth issue. I do not use WOL (wake-on-lan is a BIOS option I
have unset) and the problem happens whether I enable NAPI or not.
Currently I have NAPI disabled.

The email subject says it all; at reboot with 2.6.29, the NIC seems
to be AWOL/asleep/powered-off, and boot hangs at DHCP Discover
until the dhcpd wait-delay expires (60 secs currently). Once I have
my desktop (or console, whatever) I stop and restart the network a
few times (ifconfig eth0 down/up/down/up and ./rc.inet1 restart)
and the NIC comes back to life and gets its IP address after a
short delay.

With 2.6.28.7, the NIC gets an IP address instantly during boot, in
a half-blink of an eye, no visible delay at all.

Both kernels are identical in their configurations (same .config
file used), and neither are tainted. I have saved a dmesg from each
kernel, and they are as expected pretty similar except for the lack
of DHCP communications on the 2.6.29 dmesg.

I am suspecting the following:

commit cb52deba12f27af90a46d2f8667a64888118a888
forcedeth: power down phy when interface is down

though I could be way off; but nothing else RE:forcedeth in the
2.6.29 changelog popped out at me as a possible suspect.

Motherboard: MSI-7350 (nVidia P6N-SLI-FI)
NIC: Realtek 8211BL
DHCP server: locally connected ISC-DHCP-3.1.2, serves my LAN
OS: Slackware 11
BIOS: MSI ver 2.7

I was not sure whether I should paste a whole lot of dmesg stuff
here, or what might be useful, so I'll ask now: any further input I
can supply like dmesges or ifconfig output, lspci output, or
whatever, or you want me to test patches or try something else, I
can do. I have the time. Ask and ye shall receive. And if so, CC me
if you like, but I'll be watching the netdev list anyhow.

Many thanks,
Sasha Alexandr


-----BEGIN PGP SIGNATURE-----
Charset: iso-8859-1
Note: This signature can be verified at https://www.hushtools.com/verify
Version: Hush 3.0

wpwEAQMCAAYFAknWZe8ACgkQBdgPeajIhBnTyQP/YwsEjkI/bjCiXSCaWiwuajbXwzcK
8GKrtX8NREyvDPziWuRTbTfXKs1kjxzq0Pj6I7V4MQAdRQBdvLBLSy9Zk4dKRP5HeHh1
gG5aNGSq4wtv9gGiyzJuAkCd8P6V1DaGEsBn/oI8PGNkktAIrP7StihGsZNriEWgRi5t
nsZlNJk=
=M4S4
-----END PGP SIGNATURE-----

--
Upgrade your kitchen or bath with beautiful new countertops. Click now!
 http://tagline.hushmail.com/fc/BLSrjkqb18ARFwn2Thwp5qzhwyt209qbl4YeTqmvGynCDefzGsyhCXNPm1a/

