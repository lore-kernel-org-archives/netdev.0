From: James Harr <james@grickle.org>
Subject: Re: r8169 802.1q/MTU bug
Date: Mon, 30 May 2005 19:27:26 -0500
Message-ID: <200505301927.26110.james@grickle.org>
References: <20050530071148.GB1514@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050530071148.GB1514@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
The driver you sent gives me an error when I try to compile and load it with 
2.6.11.11:

# make
[...]
  CC [M]  drivers/net/r8169.o
  drivers/net/r8169.c: In function `rtl8169_down':
  drivers/net/r8169.c:2589: warning: implicit declaration of function
  synchronize_sched
[...]

# insmod drivers/net/r8169.ko
insmod: error inserting 'drivers/net/r8169.ko': -1 Unknown symbol in module


It does a similar thing when I try to install it:

# make modules_install
[...]
if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.6.11.11; fi
WARNING: /lib/modules/2.6.11.11/kernel/drivers/net/r8169.ko needs unknown 
symbol synchronize_sched

As I noted in a previous email, it doesn't give me this problem when I have 
jumbo frames enabled on my switch.

Since I found out my switch supported jumbo frames, I started to toy around 
with larger MTUs. When a VLAN's MTU was set to 7200, my system locked up. I 
didn't have this problem at 7196. Also, the crash problem wasn't there on a 
regular interface with no VLANs and the MTU at 7200.

Thanks,
James Harr

On Monday 30 May 2005 2:11 am, you wrote:
> James Harr <james@grickle.org> :
> [...]
>
> > I've been using a gigabit RealTek 8169 card for a while, I just recently
> > started using 802.1q with them. I stumbled upon the problem described at
> > the top of here:
> >
> > http://www.candelatech.com/~greear/vlan/howto.html
>
> Can you try the attached version of the r8169 driver with the latest
> kernel ?
>
> If the issue is still there, it is almost surely the one you link to.
> I'll give it a look when I'm back at home, it should not be long to fix.
>
> Please Cc: netdev@oss.sgi.com (it is archived and googlable).


-- 
James Harr <james@grickle.org>
http://www.grickle.org/
