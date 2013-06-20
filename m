From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 1/2] netdev: octeon_mgmt: Correct tx IFG workaround.
Date: Wed, 19 Jun 2013 18:47:34 -0700
Message-ID: <51C25F36.1040202@caviumnetworks.com>
References: <1371688820-4585-1-git-send-email-ddaney.cavm@gmail.com>  <1371688820-4585-2-git-send-email-ddaney.cavm@gmail.com>  <1371690487.2146.5.camel@joe-AO722> <51C25ACA.1070907@gmail.com> <1371692239.2146.7.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>, <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-mips@linux-mips.org>, David Daney <david.daney@cavium.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1371692239.2146.7.camel@joe-AO722>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 06/19/2013 06:37 PM, Joe Perches wrote:
> On Wed, 2013-06-19 at 18:28 -0700, David Daney wrote:
>> On 06/19/2013 06:08 PM, Joe Perches wrote:
>>> On Wed, 2013-06-19 at 17:40 -0700, David Daney wrote:
>>>> From: David Daney <david.daney@cavium.com>
>>>>
>>>> The previous fix was still too agressive to meet ieee specs.  Increase
>>>> to (14, 10).
>>> []
>>>> diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
>>> []
>>>> @@ -1141,10 +1141,13 @@ static int octeon_mgmt_open(struct net_device *netdev)
>>>>    		/* For compensation state to lock. */
>>>>    		ndelay(1040 * NS_PER_PHY_CLK);
>>>>
>>>> -		/* Some Ethernet switches cannot handle standard
>>>> -		 * Interframe Gap, increase to 16 bytes.
>>>> +		/* Default Interframe Gaps are too small.  Recommended
>>>> +		 * workaround is.
>>>> +		 *
>>>> +		 * AGL_GMX_TX_IFG[IFG1]=14
>>>> +		 * AGL_GMX_TX_IFG[IFG2]=10
>>>
>>> Why isn't the TX IFG just 96 bit times?
>>
>> I don't have a full understanding of how the transistors are wired up on
>> the chip, so I cannot accurately answer your question.  But I can say
>> that after I empirically found the previous values to get the thing to
>> work, the hardware designers independently found that the values
>> supplied in this patch are required to achieve industry standard IFGs
>> with this hardware.
>
> For one specific chip or for the Octeon entire family?
>

You will notice, if you look at the code, that there is an if statement 
that controls which chips get the special IFG treatment.

But to summarize: Only chips that have 1Gig MII ports are affected. 
Older versions (that only support 10M and 100M) do not get the adjustment.

David Daney
