From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH]: revised make xfrm_audit_log more generic patch
Date: Tue, 24 Jul 2007 11:04:56 -0400
Message-ID: <200707241104.56310.sgrubb@redhat.com>
References: <200707232146.l6NLk50u001083@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	davem@davemloft.net
To: Joy Latten <latten@austin.ibm.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <200707232146.l6NLk50u001083@faith.austin.ibm.com>
Content-Disposition: inline
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Hi,

I think we need just one other minor tweak.

On Monday 23 July 2007 17:46:05 Joy Latten wrote:
> @@ -2154,44 +2168,23 @@ EXPORT_SYMBOL(xfrm_bundle_ok);
> =C2=A0/* Audit addition and deletion of SAs and ipsec policy */
> =C2=A0
> =C2=A0void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0struct xfrm_policy *xp, struct xfrm_state=
 *x)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
u16 family, xfrm_address_t saddr, xfrm_address_t
> daddr, + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0__be32 spi, __be32 flowlabel, struct
> xfrm_sec_ctx *sctx, + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0char *buf)
> =C2=A0{
> -
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0char *secctx;
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u32 secctx_len;
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct xfrm_sec_ctx *sctx =3D=
 NULL;
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct audit_buffer *au=
dit_buf;
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int family;
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0extern int audit_enable=
d;
> =C2=A0
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (audit_enabled =3D=3D=
 0)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0return;
> =C2=A0
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0BUG_ON((type =3D=3D AUDIT_MA=
C_IPSEC_ADDSA ||
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0type =3D=3D AUDIT_MAC_IPSEC_DELSA) && !x);
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0BUG_ON((type =3D=3D AUDIT_MA=
C_IPSEC_ADDSPD ||
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0type =3D=3D AUDIT_MAC_IPSEC_DELSPD) && !xp);
> -
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0audit_buf =3D audit_log=
_start(current->audit_context, GFP_ATOMIC,
> type); if (audit_buf =3D=3D NULL)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0return;
> =C2=A0
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0switch(type) {
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0case AUDIT_MAC_IPSEC_ADDSA:
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0audit_log_format(audit_buf, "SAD add: auid=3D%u", auid)=
;
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0break;
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0case AUDIT_MAC_IPSEC_DELSA:
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0audit_log_format(audit_buf, "SAD delete: auid=3D%u", au=
id);
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0break;
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0case AUDIT_MAC_IPSEC_ADDSPD:
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0audit_log_format(audit_buf, "SPD add: auid=3D%u", auid)=
;
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0break;
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0case AUDIT_MAC_IPSEC_DELSPD:
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0audit_log_format(audit_buf, "SPD delete: auid=3D%u", au=
id);
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0break;
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0default:
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0return;
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0audit_log_format(audit_buf, =
"%s: auid=3D%u", buf, auid);
> =C2=A0
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (sid !=3D 0 &&
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0security_secid_to_secctx(sid, &secctx, &secctx_le=
n) =3D=3D 0)

The operation in buf will not be parsed by the user space tools. Let's=20
use "op=3D%s " where you have "%s: " above. Audit record fields are name=3D=
value=20
and fields separated by spaces. "op" is what we are using in other places=
 to=20
mean operation.=20

I know its a change from the records above, but we previously had some de=
tail=20
about what operation was being performed by the record type and this did =
not=20
matter so much. Now that we only have one event type, the meaning of the=20
event being recorded needs to be parsable and in a field.=20

It also wouldn't hurt to change the text being sent to this function to h=
ave a=20
hyphen instead of a space, so "SPD delete" becomes "SPD-delete". This kee=
ps=20
the parser happy.

This patch otherwise looks good.

-Steve
