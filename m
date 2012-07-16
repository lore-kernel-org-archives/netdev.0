From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: resurrecting tcphealth
Date: Mon, 16 Jul 2012 17:24:37 +0200
Message-ID: <1648678.899sL4YBmA@cpaasch-mac>
References: <cc6495b92f1df180c1ad43057ceb0b98.squirrel@webmail.univie.ac.at> <1342445557.2523.8.camel@bwh-desktop.uk.solarflarecom.com> <436a23ea8f8df4e8e3c71c369f1e3649.squirrel@webmail.univie.ac.at>
Reply-To: Christoph Paasch <christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Piotr Sawuk <a9702387@unet.univie.ac.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <436a23ea8f8df4e8e3c71c369f1e3649.squirrel@webmail.univie.ac.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 16 July 2012 17:12:26 Piotr Sawuk wrote:
> +               seq_printf(seq, "%d: %-21pI4:%u %-21pI4:%u "
> +                               "%8u %8lu %8lu %8lu %8lu%n",
> +                               st->num,
> +                               &inet->inet_rcv_saddr,
> +                               ntohs(inet->inet_sport),
> +                               &inet->inet_daddr,
> +                               ntohs(inet->inet_dport),
> +                               jiffies_to_msecs(tp->srtt),

This still doesn't gives you the correct RTT.
srtt is in jiffies * 8.

You should do jiffies_to_msecs(tp->srtt) >> 3.

The RTT is already exposed by tcp_info anyway... (see tcp_get_info() - =
where=20
you also see the bitshift)


Christoph

--=20
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=E9 Catholique de Louvain
--
