From: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Subject: Re: [PATH][RFC] acxsm: Make acx mdoular again
Date: Mon, 27 Feb 2006 11:44:38 +0100
Message-ID: <200602271144.39346.carlos@cmartin.tk>
References: <200602261710.33923.carlos@cmartin.tk> <200602271220.14853.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net,
	"Christoph Hellwig" <hch@infradead.org>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200602271220.14853.vda@ilport.com.ua>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Monday 27 February 2006 11:20, Denis Vlasenko wrote:
> > Comments are welcome and I'll split the patch if needed.
>=20
> usb.c
> =3D=3D=3D=3D=3D
> #define BOGUS_SAFETY_PADDING 0x40
>=20
> int
> acxusb_s_issue_cmd_timeo(
>         acx_device_t *adev,
>         unsigned cmd,
>         void *buffer,
>         unsigned buflen,
>         unsigned timeout)
> {
> #if ACX_DEBUG
>         return acx_s_issue_cmd_timeo_debug(adev, cmd, buffer, buflen,=20
timeout, __stringify(cmd));
> #else
>         return acx_s_issue_cmd_timeo_debug(adev, cmd, buffer, buflen,=20
timeout);
> #endif
> }
>=20
> stringify what? We want symbolic command name, not it's numeric value.
> stringifying must occur in .h file.

Missed that. The problem is that right now we need to reference the functio=
n.=20
There's no real need for it, so I'll change it.

>=20
>=20
> acx_func.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> #if ACX_DEBUG
>=20
> /* We want to log cmd names */
> int acxpci_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void=
=20
*param, unsigned len, unsigned timeout, const char* cmdstr);
> int acxusb_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void=
=20
*param, unsigned len, unsigned timeout, const char* cmdstr);
> static inline int
> acx_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void *param=
,=20
unsigned len, unsigned timeout, const char* cmdstr)
> {
>         if (IS_PCI(adev))
>                 return acxpci_s_issue_cmd_timeo_debug(adev, cmd, param, l=
en,=20
timeout, cmdstr);
>         return acxusb_s_issue_cmd_timeo_debug(adev, cmd, param, len,=20
timeout, cmdstr);
> }
> int acx_s_issue_cmd(acx_device_t *adev, unsigned cmd, void *param, unsign=
ed=20
len);
>=20
> It will recurse: acx_s_issue_cmd_timeo_debug ->=20
acxusb_s_issue_cmd_timeo_debug -> acx_s_issue_cmd_timeo_debug ->....

I forgot to remove that function. In acxusb_s_issue_timeo, it should call=20
acxusb_s_issue_cmd_timeo_{debug,nodebug}, not the generic function.

> Why do you need if (IS_PCI(adev)) at all?
>=20
> Please apply the attached style fixes on top of your patches.

Will do.

   cmn
=2D-=20
Carlos Mart=C3=ADn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
