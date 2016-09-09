From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] bonding: Prevent deletion of a bond, or the last slave
 from a bond, with active usage.
Date: Thu, 8 Sep 2016 17:57:15 -0700
Message-ID: <20160908175715.2c55e66c@xeon-e3>
References: <1473154470-15087-1-git-send-email-jasminder.kaur@hpe.com>
        <4691.1473174539@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "Kaur\, Jasminder" <jasminder.kaur@hpe.com>, vfalico@gmail.com,
        gospo@cumulusnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, vasundhara.gurunath@hpe.com,
        paulose.kuriakose.arackal@hpe.com
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4691.1473174539@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 06 Sep 2016 08:08:59 -0700
Jay Vosburgh <jay.vosburgh@canonical.com> wrote:

> Kaur, Jasminder <jasminder.kaur@hpe.com> wrote:
>=20
> >From: "Kaur, Jasminder" <jasminder.kaur@hpe.com>
> >
> >If a bond is in use such as with IP address configured, removing it
> >can result in application disruptions. If bond is used for cluster
> >communication or network file system interfaces, removing it can cause
> >system down time.
> >
> >An additional write option =E2=80=9C?-=E2=80=9D is added to sysfs bond i=
nterfaces as
> >below, in order to prevent accidental deletions while bond is in use.
> >In the absence of any usage, the below option proceeds with bond deletio=
n.
> >=E2=80=9C echo "?-bondX" > /sys/class/net/bonding_masters =E2=80=9C .
> >If usage is detected such as an IP address configured, deletion is
> >prevented with appropriate message logged to syslog. =20
>=20
> 	The issue of interfaces being arbitrarily changed or deleted is
> not specific to bonding, and could affect any networking device
> (physical or virtual).  Thus, if a facility such as this is to be
> provided, it should be generic, not specific to bonding.
>=20
> 	Separately, I'm not sure I see the value of such an option.
> Other than administrator error, I'm not sure when bonds (or other
> interfaces) would be randomly deleted.  Are you seeing that happening?
>=20
> 	Also, this patch does not prevent other errors or malicious
> change, e.g., "ip link set bondX down" or "ip addr del 1.2.3.4/24" would
> still cause the service disruption you're trying to avoid.
>=20
> 	And, lastly, what Jiri said: use netlink for new bonding
> functionality, not sysfs.
>=20
> 	-J
>=20
> >In the absence of any usage, the below option proceeds with deletion of
> >slaves from a bond.
> >=E2=80=9C echo "?-enoX" > /sys/class/net/bondX/bonding/slaves =E2=80=9C .
> >If usage is detected such as an IP address configured on bond, deletion
> >is prevented if the last slave is being removed from bond.
> >An appropriate message is logged to syslog.
> >
> >Signed-off-by: Jasminder Kaur <jasminder.kaur@hpe.com>

I agree with Jay. Unless the kernel would crash there is no reason to preve=
nt
a user with sufficient permissions from deleting a device.
