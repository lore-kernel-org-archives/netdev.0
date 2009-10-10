From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Ath5k data aborts
Date: Sat, 10 Oct 2009 14:51:26 +0200
Message-ID: <m3aazzza29.fsf@intrepid.localdomain>
References: <m3tyy8fkda.fsf@intrepid.localdomain>
	<40f31dec0910100356i470a93d0x3244867e1160e9df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org
To: Nick Kossifidis <mickflemm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:42926 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760522AbZJJMwG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 08:52:06 -0400
In-Reply-To: <40f31dec0910100356i470a93d0x3244867e1160e9df@mail.gmail.com>
	(Nick Kossifidis's message of "Sat, 10 Oct 2009 13:56:36 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nick Kossifidis <mickflemm@gmail.com> writes:

>> +#if 0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0AR5K_REG_ENAB=
LE_BITS(ah, AR5K_PCICFG,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0AR5K_PCICFG_SLEEP_CLOCK_EN);
>> +#endif

> Interesting, can you provide us with an eeprom info dump from your
> card (using ath_info tool from madwifi svn) ?
> It seems we need to skip sleep clock operation in your case.

Sure (MAC changed):

sleep_ctl reg 00000000   reset_ctl reg 00000000
 -=3D=3DDevice Information=3D=3D-
MAC Revision: 5213A (0x59)
Device type:  3
5GHz PHY Revision: 5112B (0x36)

/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D EEPROM Information =3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\
| EEPROM Version:   4.8 | EEPROM Size:  16 kbit |
| EEMAP:              1 | Reg. Domain:     0x00 |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Capabilities =3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| 802.11a Support:  yes | Turbo-A disabled: no  |
| 802.11b Support:  yes | Turbo-G disabled: no  |
| 802.11g Support:  yes | 2GHz XR disabled: no  |
| RFKill  Support:  yes | 5GHz XR disabled: no  |
| 32kHz   Crystal:  yes |                       |
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D/

/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D\
|          Calibration data common for all modes          |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
|          CCK/OFDM gain delta:             3             |
|          CCK/OFDM power delta:           10             |
|          Scaled CCK delta:               15             |
|          2GHz Antenna gain:               1             |
|          5GHz Antenna gain:               1             |
|          Turbo 2W maximum dBm:           32             |
|          Target power start:          0x1a5             |
|          EAR Start:                   0x20f             |
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D/

/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D\
|          Calibration data for 802.11a operation         |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| I power:              0x0a | Q power:              0x1e |
| Use fixed bias:       0x01 | Max turbo power:      0x20 |
| Max XR power:         0x24 | Switch Settling Time: 0x2d |
| Tx/Rx attenuation:    0x0f | TX end to XLNA On:    0x02 |
| TX end to XPA Off:    0x00 | TX end to XPA On:     0x0e |
| 62db Threshold:       0x0f | XLNA gain:            0x0d |
| XPD:                  0x01 | XPD gain:             0x05 |
| I gain:               0x0a | Tx/Rx margin:         0x0b |
| False detect backoff: 0x00 | Noise Floor Threshold: -54 |
| ADC desired size:      -32 | PGA desired size:      -80 |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| Antenna control   0:  0x00 | Antenna control   1:  0x02 |
| Antenna control   2:  0x01 | Antenna control   3:  0x00 |
| Antenna control   4:  0x00 | Antenna control   5:  0x00 |
| Antenna control   6:  0x01 | Antenna control   7:  0x02 |
| Antenna control   8:  0x00 | Antenna control   9:  0x00 |
| Antenna control  10:  0x00 | Antenna control  11:  0x00 |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| Octave Band 0:           2 | db 0:                    2 |
| Octave Band 1:           2 | db 1:                    2 |
| Octave Band 2:           2 | db 2:                    2 |
| Octave Band 3:           2 | db 3:                    2 |
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D/
/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Per rate power calibration =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\
| Freq | 6-24Mbit/s | 36Mbit/s |  48Mbit/s | 54Mbit/s |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 4920 |    18.00   |  16.00   |   14.00   |  12.00   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 5040 |    18.00   |  16.00   |   14.00   |  12.00   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 5170 |    18.00   |  16.00   |   15.00   |  13.00   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 5240 |    19.00   |  17.00   |   15.00   |  13.00   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 5320 |    19.00   |  17.00   |   15.00   |  13.00   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 5500 |    19.00   |  16.00   |   14.00   |  13.00   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 5700 |    18.00   |  16.00   |   14.00   |  13.00   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 5825 |    17.00   |  15.00   |   13.00   |  12.00   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 5360 |    19.01   |  19.01   |   19.01   |  19.01   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 5720 |    19.00   |  19.00   |   19.00   |  19.00   |
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D/
/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Per channel =
power calibration =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D\
| Freq | pwr_0 | pwr_1 | pwr_2 | pwr_3 |pwrx3_0|pwrx3_1|pwrx3_2|max_pwr=
|
|      | pcdac | pcdac | pcdac | pcdac | pcdac | pcdac | pcdac |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 4920 |  6.75 | 16.25 | 21.00 | 22.00 |  6.00 |  6.00 | 11.25 | 22.00 =
|
|      |  [25] |  [50] |  [62] |  [63] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 4980 |  6.25 | 15.75 | 21.25 | 21.75 |  4.75 |  4.50 | 11.25 | 21.75 =
|
|      |  [25] |  [50] |  [62] |  [63] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 5040 |  6.75 | 14.75 | 19.00 | 23.00 |  3.25 |  3.25 | 11.25 | 23.00 =
|
|      |  [25] |  [47] |  [57] |  [63] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 5170 |  7.25 | 15.25 | 18.50 | 23.00 |  2.25 |  2.75 | 12.00 | 23.00 =
|
|      |  [25] |  [46] |  [55] |  [61] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 5240 |  8.00 | 16.75 | 20.50 | 23.00 |  1.75 |  3.00 | 12.25 | 23.00 =
|
|      |  [25] |  [48] |  [58] |  [61] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 5320 |  8.75 | 17.50 | 21.25 | 23.00 |  2.00 |  3.50 | 13.00 | 23.00 =
|
|      |  [25] |  [48] |  [58] |  [59] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 5500 |  9.75 | 17.75 | 21.50 | 23.00 |  2.25 |  4.50 | 14.50 | 23.00 =
|
|      |  [25] |  [46] |  [56] |  [57] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 5650 | 10.25 | 18.00 | 21.00 | 23.00 |  1.75 |  5.00 | 15.00 | 23.00 =
|
|      |  [25] |  [45] |  [54] |  [56] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 5745 | 10.75 | 19.75 | 23.00 | 23.00 |  1.25 |  5.00 | 15.00 | 23.00 =
|
|      |  [25] |  [50] |  [57] |  [57] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 5825 | 10.25 | 20.00 | 22.25 | 22.25 |  0.50 |  4.75 | 14.75 | 22.25 =
|
|      |  [25] |  [50] |  [62] |  [63] |  [20] |  [35] |  [63] |       =
|
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D/

/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D\
|          Calibration data for 802.11b operation         |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| I power:              0x00 | Q power:              0x00 |
| Use fixed bias:       0x00 | Max turbo power:      0x00 |
| Max XR power:         0x00 | Switch Settling Time: 0x28 |
| Tx/Rx attenuation:    0x1e | TX end to XLNA On:    0x02 |
| TX end to XPA Off:    0x00 | TX end to XPA On:     0x07 |
| 62db Threshold:       0x1c | XLNA gain:            0x0d |
| XPD:                  0x01 | XPD gain:             0x05 |
| I gain:               0x0a | Tx/Rx margin:         0x21 |
| False detect backoff: 0x00 | Noise Floor Threshold:  -1 |
| ADC desired size:      -38 | PGA desired size:      -80 |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| Antenna control   0:  0x00 | Antenna control   1:  0x02 |
| Antenna control   2:  0x11 | Antenna control   3:  0x01 |
| Antenna control   4:  0x01 | Antenna control   5:  0x01 |
| Antenna control   6:  0x01 | Antenna control   7:  0x12 |
| Antenna control   8:  0x02 | Antenna control   9:  0x02 |
| Antenna control  10:  0x02 | Antenna control  11:  0x00 |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| Octave Band 0:           2 | db 0:                    2 |
| Octave Band 1:           2 | db 1:                    2 |
| Octave Band 2:           0 | db 2:                    0 |
| Octave Band 3:           0 | db 3:                    0 |
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D/
/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Per rate power calibration =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\
| Freq |   1Mbit/s  | 2Mbit/s  | 5.5Mbit/s | 11Mbit/s |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 2412 |    19.01   |  19.01   |   19.01   |  19.01   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 2484 |    19.00   |  19.00   |   19.00   |  19.00   |
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D/
/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Per channel =
power calibration =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D\
| Freq | pwr_0 | pwr_1 | pwr_2 | pwr_3 |pwrx3_0|pwrx3_1|pwrx3_2|max_pwr=
|
|      | pcdac | pcdac | pcdac | pcdac | pcdac | pcdac | pcdac |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 2412 |  8.00 | 15.25 | 19.50 | 23.25 |  1.50 |  3.75 | 12.00 | 23.25 =
|
|      |  [25] |  [46] |  [56] |  [63] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 2437 |  7.75 | 16.00 | 21.00 | 22.50 |  1.25 |  3.50 | 11.75 | 22.50 =
|
|      |  [25] |  [49] |  [60] |  [63] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 2472 |  7.25 | 15.75 | 21.00 | 21.75 |  0.75 |  3.25 | 11.25 | 21.75 =
|
|      |  [25] |  [50] |  [61] |  [63] |  [20] |  [35] |  [63] |       =
|
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D/

/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D\
|          Calibration data for 802.11g operation         |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| I power:              0x00 | Q power:              0x17 |
| Use fixed bias:       0x01 | Max turbo power:      0x20 |
| Max XR power:         0x26 | Switch Settling Time: 0x28 |
| Tx/Rx attenuation:    0x23 | TX end to XLNA On:    0x02 |
| TX end to XPA Off:    0x00 | TX end to XPA On:     0x0e |
| 62db Threshold:       0x1c | XLNA gain:            0x0d |
| XPD:                  0x01 | XPD gain:             0x05 |
| I gain:               0x0a | Tx/Rx margin:         0x21 |
| False detect backoff: 0x00 | Noise Floor Threshold:  -1 |
| ADC desired size:      -32 | PGA desired size:      -80 |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| Antenna control   0:  0x00 | Antenna control   1:  0x02 |
| Antenna control   2:  0x11 | Antenna control   3:  0x01 |
| Antenna control   4:  0x01 | Antenna control   5:  0x01 |
| Antenna control   6:  0x01 | Antenna control   7:  0x12 |
| Antenna control   8:  0x02 | Antenna control   9:  0x02 |
| Antenna control  10:  0x02 | Antenna control  11:  0x02 |
|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D|
| Octave Band 0:           2 | db 0:                    2 |
| Octave Band 1:           2 | db 1:                    2 |
| Octave Band 2:           0 | db 2:                    0 |
| Octave Band 3:           0 | db 3:                    0 |
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D/
/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Per rate power calibration =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\
| Freq | 6-24Mbit/s | 36Mbit/s |  48Mbit/s | 54Mbit/s |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 2412 |    19.00   |  17.01   |   16.00   |  15.01   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 2437 |    19.00   |  18.00   |   17.00   |  16.00   |
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D|
| 2472 |    19.00   |  17.01   |   16.01   |  15.00   |
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D/
/=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Per channel =
power calibration =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D\
| Freq | pwr_0 | pwr_1 | pwr_2 | pwr_3 |pwrx3_0|pwrx3_1|pwrx3_2|max_pwr=
|
|      | pcdac | pcdac | pcdac | pcdac | pcdac | pcdac | pcdac |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 2412 |  7.25 | 16.00 | 21.75 | 22.50 |  0.25 |  3.75 | 11.50 | 22.50 =
|
|      |  [25] |  [50] |  [62] |  [63] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 2437 |  7.00 | 16.25 | 20.75 | 21.75 |  0.00 |  3.50 | 11.25 | 21.75 =
|
|      |  [25] |  [50] |  [61] |  [63] |  [20] |  [35] |  [63] |       =
|
|=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=
=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=
=3D=3D|=3D=3D=3D=3D=3D=3D=3D|=3D=3D=3D=3D=3D=3D=3D|
| 2472 |  6.50 | 15.50 | 20.75 | 21.00 |  0.00 |  3.00 | 10.50 | 21.00 =
|
|      |  [25] |  [50] |  [62] |  [63] |  [20] |  [35] |  [63] |       =
|
\=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D/

GPIO registers: CR 0x00000000, DO 0x00000000, DI 0x00000001

EEPROM dump (2048 bytes)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
0000:  0013 168c 0200 0001 0000 5001 0000 1012
0008:  185f 1c0a 0100 0000 01c2 0002 c606 0001
0010:  0000 0000 0000 0000 0000 0000 0000 0000
0018:  0000 0000 0000 0000 0000 3445 1223 0001
0020:  0000 0000 0000 0000 0000 0000 0000 0000
0028:  0000 0000 0000 0000 0000 0000 0000 0000
0030:  0000 0000 0000 0000 0000 0000 0000 0000
0038:  0000 0000 0000 0000 0000 5aa5 0000 0000
0040:  0313 4943 2053 7104 1202 0400 0306 0001
0048:  0000 0500 410e 39b1 1eb5 4e2d 3056 ffff
0050:  e902 0700 0106 0000 0100 1500 0752 4101
0058:  6874 7265 736f 4320 6d6f 756d 696e 6163
0060:  6974 6e6f 2c73 4920 636e 002e 5241 3035
0068:  3130 302d 3030 2d30 3030 3030 5700 7269
0070:  6c65 7365 2073 414c 204e 6552 6566 6572
0078:  636e 2065 6143 6472 3000 0030 00ff 2100
0080:  0602 2201 0205 8d80 005b 0522 4002 8954
0088:  2200 0205 1b00 00b7 0522 8002 12a8 2201
0090:  0205 3600 016e 0522 0002 2551 2202 0205
0098:  6c00 02dc 0522 8002 37f9 2203 0205 a200
00a0:  044a 0222 0803 0822 0604 0100 2312 4534
00a8:  0222 0105 00ff 0000 0000 0000 0000 0000
00b0:  ffff ffff ffff ffff ffff ffff ffff ffff
00b8:  ffff ffff ffff ffff ffff ffff 0000 0000
00c0:  ee2b 4008 5a07 0101 420f 41a5 0101 3002
00c8:  0003 0000 0000 0000 0000 0000 0000 0000
00d0:  0000 0000 0000 0000 2d3c 0081 0000 0108
00d8:  0000 e049 2492 020f 000e b0ca 21ab 4024
00e0:  0af1 000b 0000 0000 0000 0000 0000 0000
00e8:  0000 0000 0000 0000 0000 0000 0000 0000
00f0:  0000 0000 2878 0091 0410 4148 2082 da22
00f8:  021c 0007 b0ff 01ab 4012 0001 8970 21ac
0100:  0000 0000 0000 0000 0000 0000 0000 0000
0108:  0000 0000 0000 0000 0000 288c 0091 0410
0110:  4148 2082 e022 021c 000e b0ff 21ab 4012
0118:  7851 8970 1320 21ac 00bb 0003 0000 0000
0120:  0000 0000 0000 0000 0000 0000 0000 0000
0128:  1013 1112 1440 3031 3234 0000 0000 0000
0130:  0000 0000 0000 0000 0000 0000 0000 0000
0138:  0000 0000 0000 0000 0000 0000 0000 0000
0140:  0000 0000 0000 0000 0000 0000 0000 0000
0148:  0000 0000 0000 0000 0000 0000 0000 0000
0150:  2418 4a30 6858 aa8c cdbd 411b 5854 0599
0158:  1818 192d 3f19 5755 0599 1213 192d 3b1b
0160:  5c4c 1956 0d0d 192d 3d1d 5c4a 1935 0b09
0168:  1930 4320 5c52 0d57 0c07 1931 4623 5c55
0170:  0557 0e08 1934 4727 5c56 0555 1209 193a
0178:  4829 5c54 0934 1407 193c 4f2b 5c5c 00f9
0180:  1405 193c 5029 5959 0599 1302 193b 3d20
0188:  5d4e 1d55 0f06 1930 401f 5a54 0d78 0e05
0190:  192f 3f1d 5754 0979 0d03 192d 401d 5a57
0198:  0599 0f01 192e 411c 5753 0979 0e00 192d
01a0:  3e1a 5453 0599 0c00 192a 1892 0718 3092
01a8:  0718 4a92 079a 589a 279a 689a 279a 8c9a
01b0:  071a b492 071a cd89 e698 709e 79e7 b89a
01b8:  69a6 709a 381f 899a 48a0 ac9a 385e 4c58
01c0:  5c68 bdc1 cd00 2222 2423 2464 2400 5052
01c8:  5a60 62c0 c1c9 2262 2224 2423 6323 7075
01d0:  a200 0000 0000 2868 2800 0000 0000 7075
01d8:  9da2 0000 0000 2166 6621 0000 0000 8989
01e0:  0000 0000 0000 2626 0000 0000 0000 4a56
01e8:  0000 0000 0000 3c3c 0000 0000 0000 4c68
01f0:  8cb4 bdc1 cd00 2424 2424 3c7c 3c00 7075
01f8:  ac00 0000 0000 2060 2000 0000 0000 7075
0200:  ac00 0000 0000 1d5d 1d00 0000 0000 8989
0208:  0000 0000 0000 1e1e 0000 0000 0000 ea0e
0210:  c000 0e07 8042 a204 0002 0e03 8186 9858
0218:  0000 0e01 800c 9824 0707 0e02 8063 9860
0220:  0003 03ff a210 0080 6333 03ff a214 0010
0228:  6c10 03ff a21c 1883 800a 03ff a220 0188
0230:  30c6 05ff c0fd 1001 c8f5 707f c8fc 1000
0238:  c85a 2001 c85c 2002 c85e 2001 c8fe 1001
0240:  c519 1001 cc01 2001 cc03 2001 cc8b 1001
0248:  cc8c 1001 dc92 1001 0fff 8081 1230 0001
0250:  0fff 8010 982c a002 09ff 8063 0000 0000
0258:  0000 0000 0000 0000 0000 0000 0000 0000
0260:  0000 0000 0000 0000 0000 0000 0000 0000
0268:  0000 0000 0000 0000 0000 0000 0000 0000
0270:  0000 0000 0000 0000 0000 0000 0000 0000
0278:  0000 0000 0000 0000 0000 0000 0000 0000
0280:  0000 0000 0000 0000 0000 0000 0000 0000
0288:  0000 0000 0000 0000 0000 0000 0000 0000
0290:  0000 0000 0000 0000 0000 0000 0000 0000
0298:  0000 0000 0000 0000 0000 0000 0000 0000
02a0:  0000 0000 0000 0000 0000 0000 0000 0000
02a8:  0000 0000 0000 0000 0000 0000 0000 0000
02b0:  0000 0000 0000 0000 0000 0000 0000 0000
02b8:  0000 0000 0000 0000 0000 0000 0000 0000
02c0:  0000 0000 0000 0000 0000 0000 0000 0000
02c8:  0000 0000 0000 0000 0000 0000 0000 0000
02d0:  0000 0000 0000 0000 0000 0000 0000 0000
02d8:  0000 0000 0000 0000 0000 0000 0000 0000
02e0:  0000 0000 0000 0000 0000 0000 0000 0000
02e8:  0000 0000 0000 0000 0000 0000 0000 0000
02f0:  0000 0000 0000 0000 0000 0000 0000 0000
02f8:  0000 0000 0000 0000 0000 0000 0000 0000
0300:  0000 0000 0000 0000 0000 0000 0000 0000
0308:  0000 0000 0000 0000 0000 0000 0000 0000
0310:  0000 0000 0000 0000 0000 0000 0000 0000
0318:  0000 0000 0000 0000 0000 0000 0000 0000
0320:  0000 0000 0000 0000 0000 0000 0000 0000
0328:  0000 0000 0000 0000 0000 0000 0000 0000
0330:  0000 0000 0000 0000 0000 0000 0000 0000
0338:  0000 0000 0000 0000 0000 0000 0000 0000
0340:  0000 0000 0000 0000 0000 0000 0000 0000
0348:  0000 0000 0000 0000 0000 0000 0000 0000
0350:  0000 0000 0000 0000 0000 0000 0000 0000
0358:  0000 0000 0000 0000 0000 0000 0000 0000
0360:  0000 0000 0000 0000 0000 0000 0000 0000
0368:  0000 0000 0000 0000 0000 0000 0000 0000
0370:  0000 0000 0000 0000 0000 0000 0000 0000
0378:  0000 0000 0000 0000 0000 0000 0000 0000
0380:  0000 0000 0000 0000 0000 0000 0000 0000
0388:  0000 0000 0000 0000 0000 0000 0000 0000
0390:  0000 0000 0000 0000 0000 0000 0000 0000
0398:  0000 0000 0000 0000 0000 0000 0000 0000
03a0:  0000 0000 0000 0000 0000 0000 0000 0000
03a8:  0000 0000 0000 0000 0000 0000 0000 0000
03b0:  0000 0000 0000 0000 0000 0000 0000 0000
03b8:  0000 0000 0000 0000 0000 0000 0000 0000
03c0:  0000 0000 0000 0000 0000 0000 0000 0000
03c8:  0000 0000 0000 0000 0000 0000 0000 0000
03d0:  0000 0000 0000 0000 0000 0000 0000 0000
03d8:  0000 0000 0000 0000 0000 0000 0000 0000
03e0:  0000 0000 0000 0000 0000 0000 0000 0000
03e8:  0000 0000 0000 0000 0000 0000 0000 0000
03f0:  0000 0000 0000 0000 0000 0000 0000 0000
03f8:  0000 0000 0000 0000 0000 0000 0000 0000
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
STA_ID0: 00:00:00:00:00:00
STA_ID1: 0x10000000, AP: 0, IBSS: 0, KeyCache Disable: 0
TIMER0: 0x0000fdee, TBTT: 65006, TU: 0xc749fdee
TIMER1: 0x0007ffff, DMAb: 65535, TU: 0xc749ffff (+529)
TIMER2: 0x015bcffd, SWBA: 31231, TU: 0xc76b79ff (+2194449)
TIMER3: 0x0000fddf, ATIM: 64991, TU: 0xc749fddf (-15)
TSF: 0xcad0ef1d26f6ab81, TSFTU: 48554, TU: 0xc749bdaa
BEACON: 0x007bfbe7
LAST_TSTP: 0xfbe5fbef

--=20
Krzysztof Halasa
