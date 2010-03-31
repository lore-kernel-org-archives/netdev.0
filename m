From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [r8169] WARNING: at net/sched/sch_generic.c
Date: Wed, 31 Mar 2010 15:14:26 +0300
Message-ID: <20100331121426.GB3294@swordfish.minsk.epam.com>
References: <20100331102142.GA3294@swordfish.minsk.epam.com>
 <20100331111942.GB13963@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BwCQnh7xodEAoBMC"
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100331111942.GB13963@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--BwCQnh7xodEAoBMC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On (03/31/10 07:19), Neil Horman wrote:
> On Wed, Mar 31, 2010 at 01:21:42PM +0300, Sergey Senozhatsky wrote:
> > Hello,
> > I have the following problem:
> >=20
> > [  296.337510] ------------[ cut here ]------------
> > [  296.337523] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xc=
1/0x125()
> > [  296.337527] Hardware name: F3JC               =20
> > [  296.337530] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
> > [  296.337533] Modules linked in: pktgen ipv6 snd_hwdep snd_hda_codec_s=
i3054 snd_hda_codec_realtek sdhci_pci sdhci asus_laptop sparse_keymap mmc_c=
ore led_class snd_hda_intel
> > snd_hda_codec psmouse snd_pcm snd_timer snd soundcore snd_page_alloc se=
rio_raw i2c_i801 rng_core evdev sg r8169 mii usbhid hid uhci_hcd ehci_hcd s=
r_mod cdrom sd_mod usbcore
> > ata_piix
> > [  296.337586] Pid: 0, comm: swapper Not tainted 2.6.34-rc3-dbg #74
> > [  296.337589] Call Trace:
> > [  296.337597]  [<c102e71f>] warn_slowpath_common+0x65/0x7c
> > [  296.337603]  [<c126e30c>] ? dev_watchdog+0xc1/0x125
> > [  296.337608]  [<c102e76a>] warn_slowpath_fmt+0x24/0x27
> > [  296.337613]  [<c126e30c>] dev_watchdog+0xc1/0x125
> > [  296.337620]  [<c1040039>] ? prepare_to_wait_exclusive+0x52/0x5b
> > [  296.337627]  [<c1037053>] ? run_timer_softirq+0x120/0x1eb
> > [  296.337632]  [<c10370a9>] run_timer_softirq+0x176/0x1eb
> > [  296.337637]  [<c1037053>] ? run_timer_softirq+0x120/0x1eb
> > [  296.337643]  [<c126e24b>] ? dev_watchdog+0x0/0x125
> > [  296.337650]  [<c10331c9>] __do_softirq+0x8d/0x117
> > [  296.337655]  [<c103327e>] do_softirq+0x2b/0x43
> > [  296.337660]  [<c10333a3>] irq_exit+0x38/0x75
> > [  296.337667]  [<c1015138>] smp_apic_timer_interrupt+0x6d/0x7b
> > [  296.337673]  [<c12cbada>] apic_timer_interrupt+0x36/0x3c
> > [  296.337679]  [<c104007b>] ? prepare_to_wait+0x39/0x57
> > [  296.337685]  [<c11dd835>] ? acpi_idle_enter_simple+0x119/0x144
> > [  296.337692]  [<c124d358>] cpuidle_idle_call+0x6d/0xa5
> > [  296.337697]  [<c1001b51>] cpu_idle+0x92/0xc1
> > [  296.337704]  [<c12c63d0>] start_secondary+0x1f3/0x1fa
> > [  296.337708] ---[ end trace cd4a1b50139837df ]---
> >=20
> >=20
> > Reproducing 100% with pktgen tests.
> >=20
> What kind of packets are you sending with pktgen?


Here is the sh file to run pktgen.

=3D=3D=3D=3D=3D
#!/bin/sh

function pgset() {
    local result

    echo $1 > $PGDEV

    result=3D`cat $PGDEV | fgrep "Result: OK:"`
    if [ "$result" =3D "" ]; then
         cat $PGDEV | fgrep Result:
    fi
}

function pg() {
    echo inject > $PGDEV
    cat $PGDEV
}

# Config Start Here -------------------------------------------------------=
----


# thread config
# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.

PGDEV=3D/proc/net/pktgen/kpktgend_0
  echo "Removing all devices"
 pgset "rem_device_all"=20
  echo "Adding eth0"
 pgset "add_device eth0"=20
  echo "Setting max_before_softirq 10000"
 pgset "max_before_softirq 10000"


# device config
# delay 0 means maximum speed.

CLONE_SKB=3D"clone_skb 500"
# NIC adds 4 bytes CRC
PKT_SIZE=3D"pkt_size 2048"

# COUNT 0 means forever
#COUNT=3D"count 0"
COUNT=3D"count 110110"
DELAY=3D"delay 3"

PGDEV=3D/proc/net/pktgen/eth0
  echo "Configuring $PGDEV"
 pgset "$COUNT"
 pgset "$CLONE_SKB"
 pgset "$PKT_SIZE"
 pgset "$DELAY"
 pgset "dst ???????"
 pgset "dst_mac ????????"


# Time to run
PGDEV=3D/proc/net/pktgen/pgctrl

 echo "Running... ctrl^C to stop"
 pgset "start"=20
 echo "Done"

=3D=3D=3D=3D


	Sergey
--BwCQnh7xodEAoBMC
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkuzPKIACgkQfKHnntdSXjTb2gP/YlxM3BZgTW017S7APsKvYXGA
MxY7kZpddxLTpEwiewwjtD+S2tBS+on8DzufhLys1K34NfNgsTsQ3SvVnpDBAYQ5
uI59YmNmW9coNYJJ5Q6jVPWb/SkO7j/vRFJQUsZ5kfsf7RtaKZGWDmOYwfdRXPAp
/W8PG46QyyUtAwzcqlc=
=YhbO
-----END PGP SIGNATURE-----

--BwCQnh7xodEAoBMC--
