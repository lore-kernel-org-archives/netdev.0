From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv6 net-next 00/10] OVS conntrack support
Date: Fri, 28 Aug 2015 19:25:00 -0700
Message-ID: <CANr6G5wqo-bGJKvnEkEy_odsbSKbyoTtRrFJx=M+Ykn=uHyXNA@mail.gmail.com>
References: <1440613913-10141-1-git-send-email-joestringer@nicira.com> <20150828235725.GA22045@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>, netfilter-devel@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150828235725.GA22045@vergenet.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28 August 2015 at 16:57, Simon Horman <simon.horman@netronome.com> w=
rote:
> On Wed, Aug 26, 2015 at 11:31:43AM -0700, Joe Stringer wrote:
>> The goal of this series is to allow OVS to send packets through the =
Linux
>> kernel connection tracker, and subsequently match on fields populate=
d by
>> conntrack. This functionality is enabled through a new
>> CONFIG_OPENVSWITCH_CONNTRACK option.
>>
>> This version addresses the feedback from v5, primarily checking the =
behaviour
>> is correct with different configurations such as disabling
>> CONFIG_OPENVSWITCH_CONNTRACK or disabling individual conntrack featu=
res like
>> connlabels.
>>
>> The branch below has been updated with the corresponding userspace p=
ieces:
>> https://github.com/joestringer/ovs dev/ct_20150818
>
> Hi Joe,
>
> Nice work getting this patchset in order.
>
> I am seeing the following when compiling without NF_CONNTRACK_MARK se=
t.
>
>   CC [M]  net/openvswitch//conntrack.o
> net/openvswitch//conntrack.c: In function =E2=80=98__ovs_ct_update_ke=
y=E2=80=99:
> net/openvswitch//conntrack.c:127:24: error: =E2=80=98const struct nf_=
conn=E2=80=99 has no member named =E2=80=98mark=E2=80=99
>   key->ct.mark =3D ct ? ct->mark : 0;
>                         ^
> net/openvswitch//conntrack.c: In function =E2=80=98ovs_ct_set_mark=E2=
=80=99:
> net/openvswitch//conntrack.c:195:26: error: =E2=80=98struct nf_conn=E2=
=80=99 has no member named =E2=80=98mark=E2=80=99
>   new_mark =3D ct_mark | (ct->mark & ~(mask));
>                           ^
> net/openvswitch//conntrack.c:196:8: error: =E2=80=98struct nf_conn=E2=
=80=99 has no member named =E2=80=98mark=E2=80=99
>   if (ct->mark !=3D new_mark) {
>         ^
> net/openvswitch//conntrack.c:197:5: error: =E2=80=98struct nf_conn=E2=
=80=99 has no member named =E2=80=98mark=E2=80=99
>    ct->mark =3D new_mark;
>      ^
> scripts/Makefile.build:258: recipe for target 'net/openvswitch//connt=
rack.o' failed
> make[1]: *** [net/openvswitch//conntrack.o] Error 1
> Makefile:1386: recipe for target '_module_net/openvswitch/' failed
> make: *** [_module_net/openvswitch/] Error 2

Thanks for reporting this, I sent a patch.
