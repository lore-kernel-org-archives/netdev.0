From: matthieu castet <castet.matthieu@free.fr>
Subject: Re: [test] airo : first WPA-PSK support
Date: Mon, 06 Feb 2006 21:23:18 +0100
Message-ID: <43E7B036.80202@free.fr>
References: <4369099D.3010502@free.fr> <43E7902E.9080002@free.fr>
	<1139251955.5831.9.camel@dhcp83-115.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1139251955.5831.9.camel@dhcp83-115.boston.redhat.com>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

Hi,

Dan Williams wrote:
> I can help out with the mpi350 if you'd like.  However, most of the code
> for the MPI350 should be exactly the same as with the PCMCIA version of
> the card.  They share just about everything except for the bus type.
> (unless I'm wrong?)
There are some differences for RX and TX code. Search for FLAG_MPI. But 
this should'nt be really hard to add them.
I will try to add it this weekend.


> 
> I think bits of this patch (at least the support for the WPA & RSN
> information elements in scans) should be upstreamed as soon as possible,
I don't know if you know well the code, but the driver can read/write 
some data that are indexed with RID.
The main problem is that in order to use WPA, you need to used RID 
supported only by newer firmware.
For example for WPA & RSN in scan you need to use a newer RID and a 
modified struct for data storage.
But the RID for configuration didn't change with newer firmware but 
there are extra elements in the structure.

We should check that we don't break anything for older cards/firmwares.

It is even worse, IIRC we can't mix older and new RID : this make the 
card hangs (firmware crash ?). For example the current auto WEP make the 
WPA fail.

 > I'm willing to help with that too.
You're welcome.


Matthieu
