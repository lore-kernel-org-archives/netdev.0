From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Wed, 8 Sep 2010 13:07:42 -0700
Message-ID: <AANLkTi=Ro-Vnkq75KPEdAsNEHvtF6JnmFV9i4uX2gb=H@mail.gmail.com>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<201009081142.31610.sven.eckelmann@gmx.de>
	<AANLkTimnBqkiO26wqEQOm+AgSJgQLtQmAe8R-kB6CqtZ@mail.gmail.com>
	<201009082112.14877.lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <201009082112.14877.lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 8, 2010 at 12:12 PM, Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org> wro=
te:
> On Wednesday 08 September 2010 20:22:42 Jesse Gross wrote:
>> Potentially one way to do this is to build on top of Open vSwitch. =A0It
>> contains a pretty generic flow-based kernel module for forwarding data
>> packets and making simple modifications. =A0Control packets can be sent
>> to userspace to handle the routing logic, while data packets remain in
>> the kernel for performance. =A0This would dramatically reduce the amount
>> of code that needs to be in the kernel and may even help performance
>> by simplifying the fast path.
>
> Thanks for your input.
>
> I had a quick look at the website to get an idea but I had to notice that
> there is quite a collection of daemons, kernel modules and apps. As you s=
eem
> involved in this project, could you point us to the collection of tools t=
hat
> you think we would need to achieve the following:
>
> * sending protocol traffic
> * transmitting the routing logic
> * encapsulation of the various packet types (see http://www.open-
> mesh.org/browser/trunk/batman-adv/packet.h to get an idea)
> * directly influence the traffic flow, i.e., ARQ for broadcasts, interfac=
e
> alternating, bonding, forward error correction, etc
> * layer 2 fragmentation

There are three basic components that you need running for Open
vSwitch: the main daemon, ovs-vswitchd, a lightweight configuration
manager, ovsdb-server, and the kernel module, openvswitch_mod.  You
would then be able to write a userspace process to communicate with
the daemons to handle the above.  As I mentioned, the encapsulation
would likely require some small additions to the kernel module for
your particular type of tunneling (unless you are flexible and can use
one of the existing mechanisms).  However, that would be significantly
less kernel code than this patch.  As a starting point, I would
recommend playing around with Open vSwitch as a normal switch to get a
feeling for its operation (see the INSTALL.Linux file in the source
distribution for instructions).
