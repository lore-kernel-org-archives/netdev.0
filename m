From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [PATCH Linux-2.6.7-bk19] prism54 freq to channel incorrect for 5GHz
Date: Thu, 8 Jul 2004 21:43:04 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407082143.14882.vkondra@mail.ru>
References: <200407070831.47896.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: margitsw@t-online.de (Margit Schubert-While), jgarzik@pobox.com,
        prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200407070831.47896.margitsw@t-online.de>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Wednesday 07 July 2004 09:31, Margit Schubert-While wrote:
[code skipped]
> Note that AFAIK, the 5GHz WLAN channels start at 34 (5.17 GHz)
> (but I am not sure) and I don't know the top limit (except that
> it is <= 6GHz). Maybe somebody can shed light on this.
> If there is a clear definition, that should be reflected int the code.
> And something similar for channel_to_freq.
> Apparently Japan is doing something in the 10GHz band -
> will have to look for details.
It is not 10 GHz band. They use the same 5 GHz band, exactly same frequencies, 
but channel is twice narrower - 10Mhz instead of 20Mhz as usual 802.11.

In 10Mhz channels, they use 1/2 data rates as well. I.e. 
(6,9,12,18,24,36,48,54) rates replaced by (3,4.5,6,9,12,18,24,27)

For frequencies, there are several documents. I'll try to summarize:

2.4Ghz band (as in code):
in 802.11b standard, 14 channels defined:
freq=channel*5 + 2407, channel=1..13
freq=2484, channel=14

Those "unofficial" frequencies are not defined. BTW, do anyone know document 
desctibing them?

5Ghz band (as in code):

freq=channel*5 + 5000, channel=0..200 (from standard)

For valid channels, 802.11a standard says there are 3 bands (all in US):
1: 36,40,44,48
2: 52,56,60,64
3: 149,153,157,161

TGh (regulation in Europe) adds channels 
100..140 with interval 4

Tgj (japan) spec adds new rules: 10Mhz channels I mentioned above, and channel 
formula:
freq=channel*5+dot11ChannelStartingFrequency; where 
dot11ChannelStartingFrequency may be 4000 or 5000 (as for .11a)
For channels 183 and above, it is 4000, for others - 5000

Valid channels for Japan (note some channels may have both 10 and 20 Mhz 
width, some - only one of them):

20Mhz channels: 184,188,192,196;8,12,16,34,38,42,46
10Mhz channels: 183,184,185,187,188,189;7,8,11

For TGn (high throughput) standard expected to finalize around 2006, wide 
40Mhz channels expected, with maybe some additional attributes.

After describing this whole mess, some points to pay attention:

- - channel number is not enough to determine frequency - there are same numbers  
in 2.4 and 5Ghz bands. 
- - to properly init hardware, channel witdh should be provided as well.

Thus, we probable need to use (channel,band,width) triples or (channel,domain) 
tuples, where (band,width) mapped into domain.

Vladimir
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA7ZXAqxdj7mhC6o0RAje5AJ4rDQLYmUj4QuqZgVRz71eeoq99SgCcCAWm
GQSHPKvBkPgLjbO7mONUyNI=
=hyvM
-----END PGP SIGNATURE-----
