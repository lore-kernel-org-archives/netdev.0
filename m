From: P@draigBrady.com
Subject: Re: e1000 w/ NAPI + SMP = 99% CPU utilization
Date: Wed, 09 Jun 2004 10:01:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C6D1CE.9050202@draigBrady.com>
References: <BAY1-F139xaq8HCdrWi0004e64b@hotmail.com> <16582.49526.374109.580312@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Chris Carpinello <chriscarpinello@hotmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16582.49526.374109.580312@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Chris Carpinello writes:
>=20
> Hello!
>=20
> Is seems like your network load @ ~202 Mbps gets you system into=20
> continuing polling as we see very few interrupts on your eth3.
> This means that rx_softirq reschedules itself do_softirq() kicks
> ksoftird to prevent the rx_softirq from monopolize the system.
> So now all the work gets accounted in ksoftird  And by design=20
> ->poll is strictly serialized per device to guarantee ordering and=20
> avoid cache bouncing we only see one ksoftirq used as use only have=20
> one input device.
>=20
> P=E1draig suggest binding to separate CPU's. This is normally a good=20
> thing but as you only have one input device it will not help.

agreed. All traffic is on eth3 so you can't share it over CPUs

> And didn't we just see a fix for ifconfig down oops?

yep, seems like it:
http://marc.theaimsgroup.com/?l=3Dlinux-netdev&m=3D108631346103966&w=3D2

P=E1draig.
