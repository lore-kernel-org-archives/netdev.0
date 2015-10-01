From: Wolfgang Walter <linux@stwm.de>
Subject: kernel 4.1.9: networking hangs with rcu_preempt self-detected stall, 4.1.8 works; was: Re: [PATCH 4.1 125/159] net: call rcu_read_lock early in process_backlog
Date: Thu, 01 Oct 2015 13:29:09 +0200
Message-ID: <3770693.fDE1nljnWm@stwm.de>
References: <20150926205313.363686083@linuxfoundation.org> <560A661C.7000406@tomt.net> <560A6C8B.7080105@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Anastasov <ja@ssi.bg>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	holger.hoffstaette@googlemail.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andre Tomt <andre@tomt.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <560A6C8B.7080105@tomt.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 29. September 2015, 12:48:43 schrieb Andre Tomt:
> On 29. sep. 2015 12:21, Andre Tomt wrote:
> > Meanwhile I'll revert both the mentioned net patches and see how it=
 goes.
>=20
> So that blew up as well, meaning it's not any of these two patches:
> [PATCH 4.1 124/159] net: do not process device backlog during unregis=
tration
> [PATCH 4.1 125/159] net: call rcu_read_lock early in process_backlog
>=20
> I'll be offline for a half+ day, I'll look into bisecting when back i=
f
> nobody has figured it out by then.
> --
> To unsubscribe from this list: send the line "unsubscribe stable" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

We see these rcu hangs with 4.1.9 on one of our routers, too. 4.1.8 run=
s fine.

The output I got the last time was:

[ 6488.174578] igb 000:06:00.1 eth3: Reset adapter
[ 6497.350183] INFO: rcu_preempt self-detected stall on CPU { 3}  (t=3D=
6301 jiffies g=3D383330 c=3D383329 q=3D1323)
[ 6497.350229] rcu_preempt kthread starved for 6007 jiffies!
[ 6560.311093] INFO: rcu_preempt self-detected stall on CPU { 3}  (t=3D=
25205 jiffies g=3D383330 c=3D383329 q=3D4479)
[ 6560.311140] rcu_preempt kthread starved for 24911 jiffies!
[ 6623.272005] INFO: rcu_preempt self-detected stall on CPU { 3}  (t=3D=
44109 jiffies g=3D383330 c=3D383329 q=3D7107)
[ 6623.272049] rcu_preempt kthread starved for 43815 jiffies!
[ 6633.053892] igb 000:06:00.0 eth2: Reset adapter
[ 6633.053892] rcu_preempt kthread starved for 62719 jiffies!
[ 6486.232914] INFO: rcu_preempt self-detected stall on CPU { 3}  (t=3D=
63013 jiffies g=3D383330 c=3D383329 q=3D8487)
[ 6486.233204] rcu_preempt kthread starved for 6007 jiffies!


All other hangs basically were the same, the cpu varies though.

After that the router completely hangs: networking stops working and we=
 need to restart it.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
