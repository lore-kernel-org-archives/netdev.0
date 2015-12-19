From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: =?UTF-8?Q?Re=3A_=5BPATCH=5D_veth=3A_don=E2=80=99t_modify_ip=5Fsummed=3B_doing_so?=
	=?UTF-8?Q?_treats_packets_with_bad_checksums_as_good=2E?=
Date: Sat, 19 Dec 2015 13:41:18 -0800
Message-ID: <CAM_iQpV6F8OomNx_Un6ooAEN2LmF4qzSO+82pJinU=10nEkNgQ@mail.gmail.com>
References: <CAM_iQpUOKGoNNDF2Nbut8a0q2rGY6pCXBm3NVkBMe=63K7L9bg@mail.gmail.com>
	<1450467299-7188-1-git-send-email-vijayp@vijayp.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450467299-7188-1-git-send-email-vijayp@vijayp.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 18, 2015 at 11:34 AM, Vijay Pandurangan <vijayp@vijayp.ca> =
wrote:
> Packets that arrive from real hardware devices have ip_summed =3D=3D
> CHECKSUM_UNNECESSARY if the hardware verified the checksums, or
> CHECKSUM_NONE if the packet is bad or it was unable to verify it. The
> current version of veth will replace CHECKSUM_NONE with
> CHECKSUM_UNNECESSARY, which causes corrupt packets routed from hardwa=
re to
> a veth device to be delivered to the application. This caused applica=
tions
> at Twitter to receive corrupt data when network hardware was corrupti=
ng
> packets.
>
> We believe this was added as an optimization to skip computing and
> verifying checksums for communication between containers. However, lo=
cally
> generated packets have ip_summed =3D=3D CHECKSUM_PARTIAL, so the code=
 as
> written does nothing for them. As far as we can tell, after removing =
this
> code, these packets are transmitted from one stack to another unmodif=
ied
> (tcpdump shows invalid checksums on both sides, as expected), and the=
y are
> delivered correctly to applications. We didn=E2=80=99t test every pos=
sible network
> configuration, but we tried a few common ones such as bridging contai=
ners,
> using NAT between the host and a container, and routing from hardware
> devices to containers. We have effectively deployed this in productio=
n at
> Twitter (by disabling RX checksum offloading on veth devices).
>
> This code dates back to the first version of the driver, commit
> <e314dbdc1c0dc6a548ecf> ("[NET]: Virtual ethernet device driver"), so=
 I
> suspect this bug occurred mostly because the driver API has evolved
> significantly since then. Commit <0b7967503dc97864f283a> ("net/veth: =
=46ix
> packet checksumming") (in December 2010) fixed this for packets that =
get
> created locally and sent to hardware devices, by not changing
> CHECKSUM_PARTIAL. However, the same issue still occurs for packets co=
ming
> in from hardware devices.
>
> Co-authored-by: Evan Jones <ej@evanjones.ca>
> Signed-off-by: Evan Jones <ej@evanjones.ca>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: Phil Sutter <phil@nwl.cc>
> Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Vijay Pandurangan <vijayp@vijayp.ca>


Acked-by: Cong Wang <cwang@twopensource.com>
