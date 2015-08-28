From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCHv6 net-next 00/10] OVS conntrack support
Date: Sat, 29 Aug 2015 08:57:28 +0900
Message-ID: <20150828235725.GA22045@vergenet.net>
References: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com,
	netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 26, 2015 at 11:31:43AM -0700, Joe Stringer wrote:
> The goal of this series is to allow OVS to send packets through the L=
inux
> kernel connection tracker, and subsequently match on fields populated=
 by
> conntrack. This functionality is enabled through a new
> CONFIG_OPENVSWITCH_CONNTRACK option.
>=20
> This version addresses the feedback from v5, primarily checking the b=
ehaviour
> is correct with different configurations such as disabling
> CONFIG_OPENVSWITCH_CONNTRACK or disabling individual conntrack featur=
es like
> connlabels.
>=20
> The branch below has been updated with the corresponding userspace pi=
eces:
> https://github.com/joestringer/ovs dev/ct_20150818

Hi Joe,

Nice work getting this patchset in order.

I am seeing the following when compiling without NF_CONNTRACK_MARK set.

  CC [M]  net/openvswitch//conntrack.o
net/openvswitch//conntrack.c: In function =E2=80=98__ovs_ct_update_key=E2=
=80=99:
net/openvswitch//conntrack.c:127:24: error: =E2=80=98const struct nf_co=
nn=E2=80=99 has no member named =E2=80=98mark=E2=80=99
  key->ct.mark =3D ct ? ct->mark : 0;
                        ^
net/openvswitch//conntrack.c: In function =E2=80=98ovs_ct_set_mark=E2=80=
=99:
net/openvswitch//conntrack.c:195:26: error: =E2=80=98struct nf_conn=E2=80=
=99 has no member named =E2=80=98mark=E2=80=99
  new_mark =3D ct_mark | (ct->mark & ~(mask));
                          ^
net/openvswitch//conntrack.c:196:8: error: =E2=80=98struct nf_conn=E2=80=
=99 has no member named =E2=80=98mark=E2=80=99
  if (ct->mark !=3D new_mark) {
        ^
net/openvswitch//conntrack.c:197:5: error: =E2=80=98struct nf_conn=E2=80=
=99 has no member named =E2=80=98mark=E2=80=99
   ct->mark =3D new_mark;
     ^
scripts/Makefile.build:258: recipe for target 'net/openvswitch//conntra=
ck.o' failed
make[1]: *** [net/openvswitch//conntrack.o] Error 1
Makefile:1386: recipe for target '_module_net/openvswitch/' failed
make: *** [_module_net/openvswitch/] Error 2
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
