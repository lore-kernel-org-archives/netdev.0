From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [Linux Diffserv] GRED queueing discipline and the filesch_gred.c
Date: Mon, 6 Jun 2005 20:28:14 +0200
Message-ID: <20050606182814.GI15391@postel.suug.ch>
References: <4532f31705060610486ef106a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, diffserv-general@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rahul.hari@cse06.itbhu.org
Content-Disposition: inline
In-Reply-To: <4532f31705060610486ef106a1@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Rahul Hari <4532f31705060610486ef106a1@mail.gmail.com> 2005-06-06 23:18
> UDP1 and TCP1, I am using prio. For implementing q2, I am currently
> putting UDP2,TCP2 and TCP3 in 3 different virtual queues and applying
> GRED with grio. I am providing UDP2 the highest priority and providing
> TCP2 and TCP3 equal priorities. To ensure that RED does not apply on
> the UDP2, I have set Tmax=Tmin so that Pbmax=1. But the results I am
> getting with this configuration do not match with the results that I
> have got from the simulations.

I assume Tmax being qth_max so you basically disable probability drops
which is the main point of RED. What you do is about equal as a simple
FIFO with hard queue limit comparing against a EWMA based queue length.

Depending on whether you want UDP2 to starve out the others use either
prio or cbq/htb and a GRED in rio mode with equal vq prios for TCP2 and
TCP3. The drops should be roughly proportional to their bandwidth share
but I'm not sure if this is fair enough for you.
