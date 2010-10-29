From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Fri, 29 Oct 2010 14:57:49 +0200
Message-ID: <4CCAC4CD.7000503@pengutronix.de>
References: <4CCAA3D4.8070408@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0568198885249897355=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CCAA3D4.8070408-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============0568198885249897355==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC4617654CB69CC8FA8EDD4A5"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC4617654CB69CC8FA8EDD4A5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

On 10/29/2010 12:37 PM, Tomoya wrote:
>>>> what does this loop do? why is it nessecarry? I don't like delay loo=
ps
>>>>   in the hot path of a driver.
>>> This loop is for waiting for all tx Message Object completion.
>>> This is Topcliff CAN HW specification.
>> What do you mean with "tx Message Object completion"? Is TX done not
>> signaled via interrupt?
> Yes Tx done is signaled via interrupt.
> On the other hand, register "CANTREQx" also shows the status of Message=
 Object.
> Reading the register, CAN driver can know the Message Object is empty o=
r not.
> In case of this processing, using this register is better, I think.
>=20
>> Please explain why you need to wait multiples of
>>> 500us here in the hot TX path.
> You are right. The value "500us" was too big.
> According to Topcliff document, it takes 3~6 cycles for transferring be=
tween
> register and Message Object RAM.
> Since 50MHz is, 1cycle=3D0.02usec, 6cycle=3D0.12. May be true.
> I will modify 500usec to 1usec.
>=20
>>>>> All these check if busy in the code make me a bit nervous, can you
>>>>> please explain why they are needed. A pointer to the manual is okay=
, too.
>>>> Me too. I already ask in my previous mail how long that functions
>>>> usually blocks.
>>> When accessing read/write from/to Message RAM,
>>> Since it takes much time for transferring between Register and Messag=
e RAM,
>> Much time means how many mirco-seconds?
> ditto
>=20
>>> SW must check busy flag of CAN register.
>>> This is a Topcliff HW specification.
>> Maybe the busy check could also be done *before* the Message RAM is
>> accessed to avoid (or minimize) waiting.
> Yes, *before* is right.
> If there is *after* processing, this is a bug.
> Can you see anyway ?

Sorry I don't understand what you mean.

>> Can you give us a pointer into intel's documentation?
> You have already had Intel's data sheet(Topcliff/Atom E6xx series), rig=
ht ?
> What's document for ?

You probably know the datasheet, but I don't, although I've printed
chapter 13 from the Intel Controller Hub EG20T datasheet, but it's 50+
pages. If the hardware needs the busy waiting in the hot tx path a
pointer to the respective section in the manual is a good idea. Just
something like:

    According to the Datasheet $REFERENCE section $SECTION_NUMBER we
    need to wait until the $FOO operation finished.

>>> If you figured out how to use the endianess conversion functions from=

>>> the cpu_to_{le,be}-{le,to}_to_cpup family use them here, too.

> Sorry, I misunderstood the spec of Topcliff CAN endianess.
> I have understood endianess conversion is not necessary.
> (CAN data is set as Big-Endian in Topcliff CAN register)

>> You have to change the definition of the regs struct a bit:
>>> 	u32 if1_mcont;
>>> 	u32 if1_data[4];
>>> 	u32 reserve2;
> Uh, I can't find this. Where is this ?

Here's a patch to illustrate what I meant:

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 55ec324..5ee7589 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -150,10 +150,7 @@ struct pch_can_regs {
        u32 if1_id1;
        u32 if1_id2;
        u32 if1_mcont;
-       u32 if1_dataa1;
-       u32 if1_dataa2;
-       u32 if1_datab1;
-       u32 if1_datab2;
+       u32 if1_data[4];
        u32 reserve2;
        u32 reserve3[12];
        u32 if2_creq;

>> BTW: Where can I get this Intel Hardware to improve and test the drive=
r?
> We don't know, please contact to Intel,
> Topcliff is formally called "Atom E6xx series" http://edc.intel.com/Pla=
tforms/Atom-E6xx/

> I have completed modifying for your comments excepting above.
> Receiving many comments, your indication may be dropped. If you find, p=
lease indicate again?.
> For your confirming my modification, I show current whole of CAN driver=
=2E

The driver has already been merged. Please send incremental patches
against david's net-2.6 branch.

Cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC4617654CB69CC8FA8EDD4A5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzKxNAACgkQjTAFq1RaXHPCvwCbBlPZN3JhTAIatbD1149ldBLb
IAoAoIasJRPBFVcNPhFTc+DjHJbmT0ZO
=xH16
-----END PGP SIGNATURE-----

--------------enigC4617654CB69CC8FA8EDD4A5--

--===============0568198885249897355==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0568198885249897355==--
