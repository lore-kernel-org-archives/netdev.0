From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: 3c900 Vortex Linux kernel driver documentation
Date: Tue, 14 Oct 2003 09:53:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014095349.68c96ca8.rddunlap@osdl.org>
References: <20031013183728.A300@beton.cybernet.src>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Karel =?ISO-8859-1?Q?Kulhav=FD?= <clock@twibright.com>
In-Reply-To: <20031013183728.A300@beton.cybernet.src>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Oct 2003 18:37:28 +0200 Karel Kulhav=FD <clock@twibright.com> =
wrote:

| Hello
|=20
| I have a 3c900 and want to set it to AUI and full duplex and
| having it compiled-in into the kernel, not as a module.
|=20
| I have read Documentation/networking/vortex.txt but this documentation
| covers only the modules. Why is the documentation so incomplete?
| Please tell me how to set up the card.

Please try this, although I'm not yet convinced that the 3c59x
driver calls all of the right hooks for this to work.
but good luck, and please report back on it.

--
~Randy


Parameters when driver is built into kernel image
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

There are a few parameters which may be provided to the driver as
the kernel is loaded if the driver is built into the kernel.
These parameters are passed as kernel boot options on the kernel
"command line", after the keyword "ether=3D".  The syntax for ether=3D
is:
	ether=3Dirq,base_address,mem_start,mem_end,name
where mem_start is used for certain driver options (below).

Example:
	linux console=3Dtty0 debug ether=3D11,0x320,9

If you need to pass options for multiple adapters, use "ether=3D..."
multiple times, separated by a space.

Supported driver options
------------------------

  The individual options are composed of a number of bitfields which
  have the following meanings:

  Possible media type settings
	0	10baseT
	1	10Mbs AUI
	2	undefined
	3	10base2 (BNC)
	4	100base-TX
	5	100base-FX
	6	MII (Media Independent Interface)
	7	Use default setting from EEPROM
	8       Autonegotiate
	9       External MII
	10      Use default setting from EEPROM

  When generating a value for the 'options' setting, the above media
  selection values may be OR'ed (or added to) the following:

  0x8000  Set driver debugging level to 7
  0x4000  Set driver debugging level to 2
  0x0400  Enable Wake-on-LAN
  0x0200  Force full duplex mode.
  0x0010  Bus-master enable bit (Old Vortex cards only)

  For example:

    ether=3D11,0x320,0x204

  will force full-duplex 100base-TX, rather than allowing the usual
  autonegotiation.
