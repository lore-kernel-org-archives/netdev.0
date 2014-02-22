From: Luigi Rizzo <rizzo@iet.unipi.it>
Subject: Re: netmap, VALE and netmap pipes
Date: Fri, 21 Feb 2014 17:08:14 -0800
Message-ID: <CA+hQ2+iX+wQuPP9=PaDF+t=2z3-345j71mxxAt5CWO_nHj-fJw@mail.gmail.com>
References: <CA+hQ2+gbs9aBneUaDGAnKVoPHspzc=5o+h+f_K=T+Cy8sRxr+w@mail.gmail.com>
 <5307F755.4090303@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "freebsd-net@freebsd.org" <net@freebsd.org>
To: jerry <jerry.lilijun@huawei.com>
Return-path: <owner-freebsd-net@freebsd.org>
In-Reply-To: <5307F755.4090303@huawei.com>
List-Unsubscribe: <http://lists.freebsd.org/mailman/options/freebsd-net>,
 <mailto:freebsd-net-request@freebsd.org?subject=unsubscribe>
List-Archive: <http://lists.freebsd.org/pipermail/freebsd-net/>
List-Post: <mailto:freebsd-net@freebsd.org>
List-Help: <mailto:freebsd-net-request@freebsd.org?subject=help>
List-Subscribe: <http://lists.freebsd.org/mailman/listinfo/freebsd-net>,
 <mailto:freebsd-net-request@freebsd.org?subject=subscribe>
Errors-To: owner-freebsd-net@freebsd.org
Sender: owner-freebsd-net@freebsd.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 21, 2014 at 5:03 PM, jerry <jerry.lilijun@huawei.com> wrote:

> Hi Luigi,
>
> How to use netmap pipe by pkt-gen commands?
> I have tried the commands as follows:
>   ./pkt-gen -i netmap:pipename{1 -f tx
>   ./pkt-gen -i netmap:pipename}1 -f rx  (in another terminal)
> But it works failed.
> Should the pipename be replaced with a invalid NIC name such as "eth3" in
> netmap mode?
>

netmap: expects the name of an existing device.
Arbitrary names should have the 'vale' prefix e.g.

./pkt-gen -i valexx:p{0 -f tx
./pkt-gen -i valexx:p}0 -f rx



>
> The netmap pipe works from software ring to software ring independently
> with NICs, I understand. Is that right?
>
>
correct, but the basename is used to group ports
(NICs/VALE ports and netmap pipes) that use the same
shared memory so that you can do zero copy among them.

cheers
luigi
 

> B.R.
> Jerry
>
> On 2014/2/17 18:11, Luigi Rizzo wrote:
> > Hi,
> > we have recently made a few extensions to netmap/VALE and put various
> > pieces of code on public repositories, so i thought i'd share the
> > pointers. All the code below runs with equal features and performance
> > on FreeBSD and Linux, and we are trying to upstream it in the relevant
> > projects if possible (as an example, QEMU recently added a netmap
> backend),
> > at which point some of these clone repositories will become unnecessary.
> >
> > See http://info.iet.unipi.it/~luigi/netmap for more details.
> >
> > https://code.google.com/p/netmap/
> >     The latest netmap code for FreeBSD/Linux. It has native support
> >     for certain NICs; emulated netmap over unmodified drivers;
> >     enhanced parallelism in the VALE switch (20 Mpps/source, scaling
> >     up to ~50Mpps); and a new feature called "netmap pipe" that
> >     does zero-copy blocking I/O at over 100 Mpps.
> >         Other features are the ability to allocate tons of extra
> >     netmap buffers, and configurable sharing of memory among NICs,
> >     VALE ports and netmap pipes. This increases the opportunity for
> >     zero copy operation.
>
>
>
>
>


-- 
-----------------------------------------+-------------------------------
 Prof. Luigi RIZZO, rizzo@iet.unipi.it  . Dip. di Ing. dell'Informazione
 http://www.iet.unipi.it/~luigi/        . Universita` di Pisa
 TEL      +39-050-2211611               . via Diotisalvi 2
 Mobile   +39-338-6809875               . 56122 PISA (Italy)
-----------------------------------------+-------------------------------
_______________________________________________
freebsd-net@freebsd.org mailing list
http://lists.freebsd.org/mailman/listinfo/freebsd-net
To unsubscribe, send any mail to "freebsd-net-unsubscribe@freebsd.org"
