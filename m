From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: Bad: scheduling while atomic! in 2.6.8.1
Date: Thu, 9 Sep 2004 13:56:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409091356.47325.wolfgang.walter@studentenwerk.mhn.de>
References: <200409082342.37273.wolfgang.walter@studentenwerk.mhn.de> <20040908212659.4cd99935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, greearb@candelatech.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040908212659.4cd99935.davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Donnerstag, 9. September 2004 06:26 schrieb David S. Miller:
> On Wed, 8 Sep 2004 23:42:37 +0200
>
> Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de> wrote:
> > We see the exactly the same with 2.6.8.1.
> >
> > Our host has 3 nics (all 3 are intel e100). We are using vlan, iptabl=
es
> > (no nat or connection tracking, though) and ipsec. We tested it on ot=
her
> > hardware (different mainboard, different nics) and the problem remain=
s.
> >
> > We are getting the log for every received packet, doesn't matter if t=
hese
> > are dhcp-requests, pings or something else.
>
> You have CONFIG_PREEMPT enabled don't you?
>

Yes.

> This should fix it, it's a bug in Stephen's conversion of the VLAN
> code over to use RCU locking.
>
> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/09/08 21:07:49-07:00 davem@nuts.davemloft.net
> #   [VLAN]: Fix thinko in RCU locking.
> #
> #   Signed-off-by: David S. Miller <davem@davemloft.net>
> #
> # net/8021q/vlan_dev.c
> #   2004/09/08 21:07:19-07:00 davem@nuts.davemloft.net +1 -1
> #   [VLAN]: Fix thinko in RCU locking.
> #
> diff -Nru a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> --- a/net/8021q/vlan_dev.c 2004-09-08 21:08:30 -07:00
> +++ b/net/8021q/vlan_dev.c 2004-09-08 21:08:30 -07:00
> @@ -244,7 +244,7 @@
>     /* TODO:  Add a more specific counter here. */
>     stats->rx_errors++;
>    }
> -  rcu_read_lock();
> +  rcu_read_unlock();
>    return 0;
>   }

Yes, this fixes the problem.

Thank you very much,

--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
EDV
Leopoldstra=DFe 15
80802 M=FCnchen
http://www.studentenwerk.mhn.de/
