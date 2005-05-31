From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: r8169 802.1q/MTU bug
Date: Tue, 31 May 2005 18:20:41 -0500
Message-ID: <200505311820.41469.jdmason@us.ibm.com>
References: <20050530071148.GB1514@electric-eye.fr.zoreil.com> <200505301927.26110.james@grickle.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Harr <james@grickle.org>
In-Reply-To: <200505301927.26110.james@grickle.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 30 May 2005 07:27 pm, James Harr wrote:
> Hi,
> The driver you sent gives me an error when I try to compile and load it
> with 2.6.11.11:
>
> # make
> [...]
>   CC [M]  drivers/net/r8169.o
>   drivers/net/r8169.c: In function `rtl8169_down':
>   drivers/net/r8169.c:2589: warning: implicit declaration of function
>   synchronize_sched
> [...]
>
> # insmod drivers/net/r8169.ko
> insmod: error inserting 'drivers/net/r8169.ko': -1 Unknown symbol in module
>
>
> It does a similar thing when I try to install it:
>
> # make modules_install
> [...]
> if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.6.11.11; fi
> WARNING: /lib/modules/2.6.11.11/kernel/drivers/net/r8169.ko needs unknown
> symbol synchronize_sched
>
> As I noted in a previous email, it doesn't give me this problem when I have
> jumbo frames enabled on my switch.
>
> Since I found out my switch supported jumbo frames, I started to toy around
> with larger MTUs. When a VLAN's MTU was set to 7200, my system locked up. I
> didn't have this problem at 7196. Also, the crash problem wasn't there on a
> regular interface with no VLANs and the MTU at 7200.

I wonder if this is related to the adapter breaking large frames into multiple 
descriptors.  On normal (non-VLAN) frames, this happens at MTU 8169.  I 
wonder if enabling VLAN and jumbo frames (a combination I never tried) brings 
down the threshold to MTU 7200.  

Thanks,
Jon
