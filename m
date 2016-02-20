From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: r8169 nic sometimes doesn't work after changing the mac address
Date: Sat, 20 Feb 2016 21:54:23 +0100
Message-ID: <2548019.66mqNrkh6O@fuchs>
References: <2484998.nsOrLucHGd@fuchs>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2050384.IMq3ntE0Zx"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.17.38]:55761 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427090AbcBTVEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2016 16:04:11 -0500
In-Reply-To: <2484998.nsOrLucHGd@fuchs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2050384.IMq3ntE0Zx
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Saturday 12 December 2015 22:43:45 Maximilian Engelhardt wrote:
> Hello,
> 
> I'm using a Lenovo TinkPad Edge E135 notebook that has a Realtek wired
> network interface inbuilt. Under some conditions the nic doesn't work after
> changing the mac address.
> 
> It took me some time to figure out that it makes a difference if I (re)boot
> my notebook with or without the power supply plugged in. When I boot the
> system with the power supply plugged in everything does work fine as
> expected. But if I boot with the power supply unplugged and I change the
> mac address the network card doesn't work.
> 
> 
> This is how I am testing and how I can reproduce the behavior on my system:
> 
> * Boot Linux (Debian stable with a newer kernel)
> * Network is still turned off, only loopback is enabled by default in my
> setup. * I run the following commands:
>   ip link set dev eth0 address 00:12:0c:96:a7:2e # a randomly generated mac
>   ip link set dev eth0 up
>   ip addr add dev eth0 10.0.252.50/24
>   ip route add default via 10.0.252.1
> 
> When the notebook is booted with the power supply plugged in the network is
> working as expected, e. g. I can ping the gateway.
> 
> But when the notebook was booted without the power supply attached the
> network is not working e. g. pinging the gateway doesn't get any replies.
> 
> I found two ways to get the network working from this state (beside
> rebooting with power plugged in):
> 
> * If I enable promiscous mode the network connections are working again:
>   # ip link set dev eth0 promisc on
> 
> * Alternatively I can set the same mac address again while the interface is
> up:
>   # ip link set dev eth0 address 00:12:0c:96:a7:2e # same mac as before
> 
> 
> So it seems like a mac filter in the network card is not set up right.
> 
> 
> Attached are dmesg output of a boot with and without power supply attached
> as well as the output of lspci -vvv.
> 
> 
> Please let me know If you need more information.
> 
> Thanks,
> Maxi


Hello,

Anyone had a look at this? I can confirm that the problem is still present in 
kernel 4.4.2.

I just did a quick tcpdump and found out that packets are transmitted fine, but 
the replay of the other end gets lost somewhere in the nic/driver e. i. it 
seems to never reach the kernel network stack.

Please let me know if you need more information from me.

Thanks,
Maxi

--nextPart2050384.IMq3ntE0Zx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJWyNJ/AAoJEIHqZH0kK9IVeHQP/R613g7DcR7cdk2R06F2i+qw
OR1jgdQQXuVmtaEjiDiPdgsTkMeXTfZBZnZmzqgpQVa0kvkf3p7hORvSVQ0MZQXq
b5xb/YGGhqil/k+vMWDEZemTYowbVxeru16FWS8VM22KgPiwl4m6GgbDSv2ydA6T
3PvtS0xD4mstATFu/zYzl1Y+d/09qfeEMI9OGR1XNT3E4tCgBTiZmSick/FO+dkm
QlW3LvBI4Lh0eQ2gPQfZ4zJVDVM5djw4FyMNw+NO+SpSm40wdg/tc97dJhg143dP
8CqxfN5gdW4hxKUWZ3tWsdzpHgpY8ZtUDJUpumczkhSsbuWqmGlmfcnoppGdj7bG
d7CH9OigF2nB1ZkwOIW5P8p+hkqlfP1HiAvdGGXwD0xkcEwEKUMr7MGIKUXD88ta
1lHdxnd/gBLZN2t2QUx+GR2BlDq84lhDC9/PVShOyfsaJD/qq9b7YRcyRxT3rUN+
2SnthnpHBh+7x+PlRuIeym1e+ZuXVTOzgNZEytd6MYXRtPQ7/0xgq9nUgYmSmqjX
ZN2K0AGWxBpTfPhLj87OGxc27HYl4tWgOrq3j7Xl7Gd7Mfp9j2+3c9OCp80GOuwO
Bzgyut6kXulS4rKuH3AHBryotZGvCs0RkV1S30GagICmHPSg0CGOKYwlnsAA1VxX
bUhTDtCZHx4/yPc23Zvm
=3lnB
-----END PGP SIGNATURE-----

--nextPart2050384.IMq3ntE0Zx--
