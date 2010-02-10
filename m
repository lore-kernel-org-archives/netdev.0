From: Mitch Bradley <wmb-D5eQfiDGL7eakBO8gow8eQ@public.gmane.org>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 08:35:30 -1000
Message-ID: <4B72FC72.6080301@firmworks.com>
References: <4dfe033d-c308-45e0-9c7e-9fc60c6cad8f@SG2EHSMHS013.ehs.local>
	<fa686aa41002100843o7a1d4160q8fb01768ad48dcf4@mail.gmail.com>
	<7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>
	<fa686aa41002101014s43682e3cra55854b82a40bb5f@mail.gmail.com>
	<4B72FB38.7080909@firmworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree-discuss <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Andy Fleming <afleming-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <4B72FB38.7080909-D5eQfiDGL7eakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

>
>>
>> On Wed, Feb 10, 2010 at 9:52 AM, John Linn <John.Linn-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org> wrote:
>>  
>>>> >> -----Original Message-----
>>>> >> From: glikely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org [mailto:glikely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org] On 
>>>> Behalf Of Grant Likely
>>>> >> Sent: Wednesday, February 10, 2010 9:44 AM
>>>> >> To: John Linn; devicetree-discuss; netdev
>>>> >> Subject: Re: phy address in the device tree, vs auto probing
>>>> >>
>>>> >> (cc'ing devicetree-discuss and netdev mailing lists)
>>>> >>
>>>> >> On Tue, Feb 9, 2010 at 4:23 PM, John Linn <John.Linn-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org> 
>>>> wrote:
>>>>      
>>>>> >> > Hi Grant,
>>>>> >> >
>>>>> >> > I notice that the OF driver for the mdio bus is not doing 
>>>>> auto probing.
>>>>> >> >
>>>>> >> > As we start putting in the phy layer in the emac drivers, the 
>>>>> device
>>>>> >> > trees tend to have the phy address in them, but we're not 
>>>>> sure we really
>>>>> >> > like that.
>>>>> >> >
>>>>> >> > We really think that being able to let the kernel find the 
>>>>> phy address
>>>>> >> > is a big benefit, otherwise this is one other piece of info 
>>>>> the user has
>>>>> >> > to know and get right.
>>>>> >> >
>>>>> >> > Am I missing something here?
>>>>>         
>>>> >>
>>>> >> No, you're not really missing something, but there is an inherent
>>>> >> complexity in what you're wanting to do.  Like i2c, MDIO is one of
>>>> >> those busses that is hard to probe reliable.  Some PHYs respond on
>>>> >> more than one address, and there is no way to determine which MAC a
>>>> >> PHY is wired up to.  Many PHYs can live on a single MDIO bus.  MACs
>>>> >> with their own MDIO busses may still get wired to a PHY on a 
>>>> different
>>>> >> bus.
>>>> >>
>>>> >> In the simple case where there is a one:one:one relationship 
>>>> between
>>>> >> MAC, MDIO bus and PHY, then it should be okay to probe the PHY,
>>>> >> correct?  The question then must be asked; how does the kernel
>>>> >> determine that it can use the simple case?  Nobody has yet 
>>>> defined a
>>>> >> way to describe that in the device tree; mostly because nobody has
>>>> >> needed to yet.
>>>> >>
>>>> >> So, it is possible to do what you want, but you need a way to
>>>> >> *explicitly* ask for that behaviour.  ie, some way to indicate in a
>>>> >> MAC node which MDIO bus the phy is on, and that the phy needs to be
>>>> >> probed for.  I think this should only be an option when the MDIO 
>>>> bus
>>>> >> has only one PHY.  Come up with a proposal and post it to the
>>>> >> devicetree-discuss mailing list.
>>>>       
>>> >
>>> > Here's a couple ideas. See what everyone thinks as I'm not stuck 
>>> on either.
>>> >
>>> > Thanks,
>>> > John
>>> >
>>> > 1. What if we just don't specific a phy address with a reg 
>>> property which would specify to auto probe it and find the phy as 
>>> illustrated below?
>>> >
>>> >
>>> >                Ethernet_MAC: ethernet@81000000 {
>>> >                        #address-cells = <1>;
>>> >                        #size-cells = <1>;
>>> >                        phy-handle = <&phy0>;
>>> >                        mdio {
>>> >                                #address-cells = <1>;
>>> >                                #size-cells = <0>;
>>> >                                phy0: phy@7 {
>>> >                                } ;
>>> >                        } ;
>>> >
>>> > 2. Or a special value (-1 or something not 0 - 31) in the phy 
>>> address that specifies to auto probe as illustrated below.
>>> >                                phy0: phy@7 {
>>> >                                        reg = <-1>;
>>> >                                } ;
>>>     
>>
>> I don't like abusing the reg property in this way.  I wonder if a new
>> empty property would be a better way to indicate this.  Maybe
>> "phy-probe-address;"?  It would also be important to specify in the
>> binding that only one phy node is allowed when phy-probe-address is
>> used.
>>
>> Also, without a known reg the 'phy@7' name is inaccurate.  Drop the @7.
>>
>> Scott, Andy: any thoughts?
>>   
>
> This case is somewhat similar to "wildcard nodes" on unprobed SCSI 
> buses, going all the way back to pre-1275 Open Boot.  Since full 
> probing of a SCSI bus could take a really long time (spin-up delays 
> etc), Open Boot would usually create a bus node for the host 
> controller and populate it with a disk node and a tape node, neither 
> of which had a reg property.  That meant that there was a good chance 
> that you might find such devices on that bus, but their specific SCSI 
> bus addresses had not yet been determined.  In addition to those 
> wildcard nodes, similar nodes with extant reg properties could also 
> appear, asserting the presence of a known device at the given 
> address.  The node matching algorithm first looks for an exact match 
> with a reg property, and failing that, looks for a wildcard match.
>

FYI, wildcard matching is defined in section 4.3.3 clause (b) and 
section 4.3.5 of IEEE 1275-1994.
