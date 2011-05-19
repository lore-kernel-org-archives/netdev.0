From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next-2.6] netpoll: disable netpoll when enslave a
 device
Date: Thu, 19 May 2011 13:13:29 +0800
Message-ID: <4DD4A6F9.4010002@redhat.com>
References: <1305712845-11762-1-git-send-email-amwang@redhat.com> <20110518105558.GA3203@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Neil Horman <nhorman@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Ferenc Wagner <wferi@niif.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110518105558.GA3203@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2011=E5=B9=B405=E6=9C=8818=E6=97=A5 18:56, Neil Horman =E5=86=
=99=E9=81=93:
> On Wed, May 18, 2011 at 06:00:35PM +0800, Amerigo Wang wrote:
=2E..
>> -			case NETDEV_GOING_DOWN:
>>   			case NETDEV_BONDING_DESLAVE:
>> +			case NETDEV_ENSLAVE:
>>   				nt->enabled =3D 0;
>>   				stopped =3D true;
>>   				break;
> This wasn't introduced by this patch, but looking at it made me reali=
ze that
> nt->enabled, if it passes through this code path, doesn't properly tr=
ack weather
> or not netpoll_setup has been called on this interface.  If you look =
at
> drop_netconsole_target, you'll see we only call netpoll_cleanup_targe=
t if
> nt->enabled is set.  We should probably change the nt->enabled check =
there, and
> in store_enabled to be if (nt->np.dev), like we do in the NETDEV_UNRE=
GISTER case
> in netconsole_netdev_event.

Yeah, also note that we can change ->enabled via configfs too.
I guess we probably need to fix this in another patch...


>> +#define NETDEV_ENSLAVE		0x0014
>>
> Nit:
> Shouldn't this be NETDEV_BONDING_ENSLAVE, to keep it in line with
> NETDEV_BONDING_DESLAVE above?

Actually that is my first thought, but I plan to use this in bridge
case too, because using netconsole on a device underlying a bridge
makes little sense too. Thus, I prefer NETDEV_ENSLAVE to
NETDEV_BONDING_ENSLAVE.

>
>>   #define SYS_DOWN	0x0001	/* Notify of system down */
>>   #define SYS_RESTART	SYS_DOWN
>>
>
>
> Other than those two points, this looks good to me

Thanks for review.
