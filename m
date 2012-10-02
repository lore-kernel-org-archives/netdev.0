From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: tg3 driver upgrade (Linux 2.6.32 -> 3.2) breaks IBM Bladecenter SoL
Date: Tue, 02 Oct 2012 14:07:57 +0200
Message-ID: <87a9w5dqle.fsf@lant.ki.iif.hu>
References: <87txuhho5z.fsf@lant.ki.iif.hu>
	<1349083982.5420.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Matt Carlson" <mcarlson@broadcom.com>,
	"Grant Likely" <grant.likely@secretlab.ca>,
	"Rob Herring" <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org, wferi@niif.hu
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349083982.5420.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	(Michael Chan's message of "Mon, 1 Oct 2012 02:33:02 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael Chan" <mchan@broadcom.com> writes:

> On Fri, 2012-09-28 at 22:45 +0200, Ferenc Wagner wrote: 
> 
>> Upgrading the kernel on our HS20 blades resulted in their SoL (serial
>> over LAN) connection being broken.  The disconnection happens when eth0
>> (the interface involved in SoL) is brought up during the boot sequence.
>> If I later "ip link set eth0 down", then the connection is restored, but
>> "ip link set eth0 up" breaks it again on 3.2.  ethtool -a, -c, -g, -k
>> and -u show no difference; ethtool -i on the 2.6.32 kernel reports:
>> 
>> driver: tg3
>> version: 3.116
>> firmware-version: 5704s-v3.38, ASFIPMIs v2.47
>> bus-info: 0000:05:01.0
>> 
>> In the 3.2 kernel the driver version is 3.121.
>
> 2.6.32 to 3.2 is a big jump.  Can you narrow this down further?  It will
> be hard for us to find a HS20 with 5704 to test this.  Thanks.

I'm done with bisecting it: the first bad commit is:

commit dabc5c670d3f86d15ee4f42ab38ec5bd2682487d
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Thu May 19 12:12:52 2011 +0000

    tg3: Move TSO_CAPABLE assignment
    
    This patch moves the code that asserts the TSO_CAPABLE flag closer to
    where the TSO capabilities flags are set.  There isn't a good enough
    reason for the code to be separated.
    
    Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
    Reviewed-by: Michael Chan <mchan@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

On the other hand, losing the SoL console even temporarily during boot
(as it happens with a minimal kernel before this commit) isn't nice
either.  I'll try to look after that, too, just mentioning it here...
-- 
Regards,
Feri.
