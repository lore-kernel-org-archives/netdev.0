From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH v3] sh_eth: ensure pm_runtime cannot suspend the device
 during init
Date: Thu, 20 Mar 2014 22:02:43 +0100
Message-ID: <532B5773.7020700@codethink.co.uk>
References: <1395336877-12402-1-git-send-email-ben.dooks@codethink.co.uk> <3894339.LtO9XLDneL@avalon> <532B3CD7.5050005@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, davem@davemloft.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <532B3CD7.5050005@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/03/14 20:09, Sergei Shtylyov wrote:
> Hello.
>
> On 03/20/2014 09:01 PM, Laurent Pinchart wrote:
>
>>> The pm_rumtime work queue is causing the device to be suspended during
>>> initialisation, thus the initialisation may not be able to access
>>> registers
>>> properly. As the code is called from a work queue, it is possible
>>> that this
>>> is not seen from certain configurations/builds due to the asynchronos
>>> nature of the code.
>
>>> Another issue has also been found where the network device registration
>>> calls back into the driver thus causing further pm_runtime calls that
>>> also caused issues with the MDIO bus code.
>
>>> Use pm_runtime_get_sync() and pm_runtime_put() to ensure that the
>>> pm system does not suspend it during the probe() call and remove the
>>> now unnecessary pm_runtime_resume() call.
>
>>> This fixes the external abort that can cause /sbin/init or other such
>>> init processed to die.
>
>>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>>> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
>
>>> ---
>>> Cc: sergei.shtylyov@cogentembedded.com
>>> Cc: laurent.pinchart+renesas@ideasonboard.com
>>> cc: netdev@vger.kernel.org
>
>>> Note, Laurent this should probably be applied before your
>>> current series as it may require changes to the exit sequence.
>
>> Would you like me to include the patch in that series when I'll send a
>> pull
>> request ?
>
>>> Fixes from v1:
>>>     - use pm_runtime_put() over pm_runtime_put_sync() as
>>>       we do not need to guaranteed the device has powered
>>>            off after probe.
>
>>> Fixed from v2:
>>>     - call pm_runtime_put() in error path

Thanks, that looks like another issue that got missed.
I will submit v3


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
