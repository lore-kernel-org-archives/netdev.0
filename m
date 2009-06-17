From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH][Resend 2][BUILD FAILURE 04/04] Next June 04:PPC64 randconfig [drivers/net/ucc_geth.o]
Date: Wed, 17 Jun 2009 08:07:47 -0500
Message-ID: <6E26D0A1-0FE5-4179-9DA8-FDF0E3D417DA@kernel.crashing.org>
References: <20090611033705.20842.75501.sendpatchset@subratamodak.linux.ibm.com> <1245048719.5239.10.camel@subratamodak.linux.ibm.com> <1245243097.4870.3.camel@subratamodak.linux.ibm.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>,
	Nathan Lynch <ntl@pobox.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Tony Breeds <tony@bakeyournoodle.com>, michael@ellerman.id.au
To: subrata@linux.vnet.ibm.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1245243097.4870.3.camel@subratamodak.linux.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jun 17, 2009, at 7:51 AM, Subrata Modak wrote:

> On Mon, 2009-06-15 at 12:22 +0530, Subrata Modak wrote:
>> Hi Li/Nathan,
>>
>> On Thu, 2009-06-11 at 09:07 +0530, Subrata Modak wrote:
>>> Hi Nathan,
>>>
>>>> On Wed, 2009-06-10 at 21:28 -0500, Nathan Lynch wrote:
>>>> Subrata Modak <subrata@linux.vnet.ibm.com> writes:
>>>>
>>>>> On Thu, 2009-06-11 at 11:05 +1000, Stephen Rothwell wrote:
>>>>>> Hi Subrata,
>>>>>>
>>>>>> On Wed, 10 Jun 2009 23:13:23 +0530 Subrata Modak <subrata@linux.vnet.ibm.com 
>>>>>> > wrote:
>>>>>>>
>>>>>>> 	/* Find the TBI PHY.  If it's not there, we don't support  
>>>>>>> SGMII */
>>>>>>> -	ph = of_get_property(np, "tbi-handle", NULL);
>>>>>>> +	ph = (phandle *)of_get_property(np, "tbi-handle", NULL);
>>>>>>
>>>>>> You don't need this cast because of_get_property() returns  
>>>>>> "void *".
>>>>>
>>>>> Stephen,
>>>>>
>>>>> True. But without this gcc complains:
>>>>>
>>>>> CC [M]  drivers/net/ucc_geth.o
>>>>> drivers/net/ucc_geth.c: In function bucc_geth_probeb:
>>>>> drivers/net/ucc_geth.c:3824: warning: assignment discards  
>>>>> qualifiers
>>>>> from pointer target type
>>>>
>>>> ph should be declared const phandle *.  Look at other uses of
>>>> of_get_property.
>>>>
>>>
>>> Ok fine. Here is a revised patch again.
>>>
>>> Subject: [PATCH][Resend 2][BUILD FAILURE 04/04] Next June 04:PPC64  
>>> randconfig [drivers/net/ucc_geth.o]
>>> Reference(s):
>>> http://lkml.org/lkml/2009/6/4/241,
>>> http://lkml.org/lkml/2009/6/10/338,
>>>
>>> Fix the following build error:
>>>
>>> drivers/net/ucc_geth.c: In function bucc_geth_probeb:
>>> drivers/net/ucc_geth.c:3822: error: 'ph' undeclared (first use in  
>>> this function)
>>> drivers/net/ucc_geth.c:3822: error: (Each undeclared identifier is  
>>> reported only once
>>> drivers/net/ucc_geth.c:3822: error: for each function it appears  
>>> in.)
>>> drivers/net/ucc_geth.c:3832: error: 'mdio' undeclared (first use  
>>> in this function)
>>> make[2]: *** [drivers/net/ucc_geth.o] Error 1
>>>
>>> Signed-off-by: Subrata Modak <subrata@linux.vnet.ibm.com>
>>> ---
>>
>> Is there anything else to be done in this patch. If this is OK, can  
>> this
>> be applied. I am not sure, but, i find Li Yang as the maintainer for
>> this in linux*/MAINTAINERS file. Kindly let me know if this patch  
>> needs
>> to be revisited for some other issue(s).
>
> Li,
>
> Any thoughts on this patch ?
>
>
> Regards--
> Subrata
>
>>
>> Regards--
>> Subrata
>>
>>>
>>> --- linux-2.6.30-rc8/drivers/net/ucc_geth.c.orig	2009-06-10  
>>> 11:58:39.000000000 -0500
>>> +++ linux-2.6.30-rc8/drivers/net/ucc_geth.c	2009-06-10  
>>> 22:28:13.000000000 -0500
>>> @@ -3595,6 +3595,8 @@ static const struct net_device_ops ucc_g
>>>
>>> static int ucc_geth_probe(struct of_device* ofdev, const struct  
>>> of_device_id *match)
>>> {
>>> +	struct device_node *mdio;
>>> +	const phandle *ph;
>>> 	struct device *device = &ofdev->dev;
>>> 	struct device_node *np = ofdev->node;
>>> 	struct net_device *dev = NULL;
>>>
>>> ---
>>> Regards--
>>> Subrata
>>>

I'm confused by the proposed fix as we already have *mdio & *ph  
defined in this function:

static int ucc_geth_probe(struct of_device* ofdev, const struct  
of_device_id *match)
{
         struct device *device = &ofdev->dev;
         struct device_node *np = ofdev->node;
         struct device_node *mdio;
         struct net_device *dev = NULL;
         struct ucc_geth_private *ugeth = NULL;
         struct ucc_geth_info *ug_info;
         struct resource res;
         struct device_node *phy;
         int err, ucc_num, max_speed = 0;
         const phandle *ph;
         const u32 *fixed_link;
         const unsigned int *prop;
         const char *sprop;
         const void *mac_addr;
...

- k