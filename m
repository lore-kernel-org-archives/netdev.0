From: P@draigBrady.com
Subject: Re: 2.6.10 - "netdev=" kernel boot commands and the Intel e1000 nic
Date: Fri, 11 Mar 2005 14:27:08 +0000
Message-ID: <4231AABC.8040101@draigBrady.com>
References: <13A26154A563124B876A26F0EF0CE1ED032C9299@HFCCINFEXCH501.AMERICAS.CORP.LOCAL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
To: Alex Upton <AUpton@island.com>
In-Reply-To: <13A26154A563124B876A26F0EF0CE1ED032C9299@HFCCINFEXCH501.AMERICAS.CORP.LOCAL>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alex Upton wrote:
> Hello All,
>=20
> For about 3.5 days now I've been trying to swap eth0 and eth1 devices
> through use of the netdev kernel boot switch.
>=20
> The scenario:
>=20
> We have a system with onboard NICS and a PCI Intel e1000 Fiber NIC
> installed. This particular system by default forces the NIC inside the
> PCI slot to always default to eth0. We want to have ultimate control as
> to which NIC is deemed worthy enough to become eth0. We are using an
> entirely monolithic kernel via a PXE driven build and prefer not to
> support use of modules.
>=20
> If anyone has any suggestions or insight on how to work with netdev and
> the e1000 properly it would be greatly appreciated!

I've found using a higher level script with heuristics
is the only way to order nics generically as I want. for e.g.

if ethtool eth0 | grep -q "Port: FIBRE"; then
     ip link set dev eth0 name not_eth0
     ip link set dev eth1 name eth0
fi

you get the idea...

P=E1draig.
