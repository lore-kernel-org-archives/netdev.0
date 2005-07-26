From: P@draigBrady.com
Subject: Re: Re: drop counts
Date: Tue, 26 Jul 2005 09:36:34 +0100
Message-ID: <42E5F612.2010405@draigBrady.com>
References: <42DCDCAF.1060005@draigBrady.com> <42DCF0F7.6000704@draigBrady.com> <Pine.WNT.4.63.0507201505370.1936@jbrandeb-desk.amr.corp.intel.com> <42DFA4E9.5060602@draigBrady.com> <Pine.WNT.4.63.0507251041150.832@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.WNT.4.63.0507251041150.832@jbrandeb-desk.amr.corp.intel.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> On Thu, 21 Jul 2005, P@draigBrady.com wrote:
>=20
>> In 2.6.12 this changed to:
>>
>> packets =3D gprc
>> dropped =3D mpc
>> fifo =3D mpc
>> missed =3D mpc
>>
>> I think there still is a problem. Notice that /proc/net/dev
>> reports rx_dropped + rx_missed_errors for the drop column,
>> and so will be double counting drops currently.
>> Therefore I think we should be doing:
>>
>> packets =3D gprc
>> dropped =3D 0
>> fifo =3D rnbc
>> missed =3D mpc
>=20
>=20
> Double counting drops may be an issue, and I believe we should make tha=
t=20
> change.

great.

> but I don't think its the right thing to report rnbc in fifo=20
> errors (there was actually no error).
>=20
>> I'm putting rnbc in fifo as it's not accumulated into
>> anything else in the kernel. Also it's good to have
>> it reported as one can see when there is pressure on
>> the e1000 driver buffer. This is useful for tuning its size
>> to protect against drops and latency.
>=20
>=20
> Whenever I want the RNBC numbers I simply look into ethtool -S eth0, an=
d=20
> that allows me to tune.  I see no reason to "reuse" the fifo errors sta=
t=20
> with misleading data.

Fair enough if rnbc is actually reported.
ethtool -S doesn't report it with my driver,
but I see this stat has been added to the
latest driver at least.

So I agree on both points.

thanks!

--=20
P=E1draig Brady - http://www.pixelbeat.org
--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
