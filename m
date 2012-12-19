From: Joe Jin <joe.jin@oracle.com>
Subject: Re: [E1000-devel] 82571EB: Detected Hardware Unit Hang
Date: Wed, 19 Dec 2012 11:04:02 +0800
Message-ID: <50D12EA2.3030907@oracle.com>
References: <509B5038.8090304@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com> <50A30656.6090508@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA8913348B105@ORSMSX102.amr.corp.intel.com> <50A43828.6000702@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA8913349A0B4@ORSMSX102.amr.corp.intel.com> <50A9C5CC.1030300@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA8913349EB41@ORSMSX102.amr.corp.intel.com> <50AB8471.7080607@oracle.com> <9B4A1B1917080E46B64F07F2989DADD62F2D62D6@ORSMSX102.amr.corp.intel.com> <50B41077.3080009@oracle.com>	<b46b84cf-3688-4fd7-b741-4e96f2663517@default> <9B4A1B1917080E46B64F07F2989DADD62F2D8070@ORSMSX102.amr.corp.intel.com> <1354039840.2701.14.camel@bwh-desktop.uk.solarflarecom.com> <50B5CBD2.5020804@oracle.com> <9B4A1B1917080E46B64F07F2989DADD62F2D8A
 AC@ORSMSX102.amr.corp.intel.com> <CABawtvPrz=z_CLCvPeXkky7COyhjPyfBu3QCTbiiPpvr+5bicg@mail.gmail.com> <9B4A1B1917080E46B64F07F2989DADD638C60A9B@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ethan Zhao <ethan.kernel@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Mary Mcgrath <mary.mcgrath@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>
To: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD638C60A9B@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I backported mps commits and ask customer pass "pci=pcie_bus_peer2pee" to kernel
to limited MPS to 128 and issue disappeared, sound like this is a BIOS bug.

Thanks all of your help.

Best Regards,
Joe

On 11/29/12 23:52, Fujinaka, Todd wrote:
> Someone else pointed this out to me locally. If you have a non-client BIOS, you should be able to set the MaxPayloadSize using setpci. You have to make sure that you're being consistent throughout all the associated links.
> 
> Todd Fujinaka
> Technical Marketing Engineer
> LAN Access Division (LAD)
> Intel Corporation
> todd.fujinaka@intel.com
> (503) 712-4565
> 
> 
> -----Original Message-----
> From: Ethan Zhao [mailto:ethan.kernel@gmail.com] 
> Sent: Wednesday, November 28, 2012 7:10 PM
> To: Fujinaka, Todd
> Cc: Joe Jin; Ben Hutchings; Mary Mcgrath; netdev@vger.kernel.org; e1000-devel@lists.sf.net; linux-kernel@vger.kernel.org; linux-pci
> Subject: Re: [E1000-devel] 82571EB: Detected Hardware Unit Hang
> 
> Joe,
>     Possibly your customer is running a kernel without source code on a platform whose vendor wouldn't like to fix BIOS issue( Is that a HP/Dell server ?).
>     Anyway, to see if is a payload issue or,  you could change the payload size with setpci tool to those devices and set the link retrain bit to trigger the link retraining to debug the issue and identity the root cause.  I thinks it is much easier than modify the BIOS or  eeprom of NIC.
> 
>     e.g.
>    set device control register to 0f 00   (128 bytes payload size)
>    #   setpci -v -s 00:02.0 98.w=000f
>    set device link control register to 60h (retrain the link)
>    #  setpci -v -s 00:02.0 a0.b=60
> 
>   Hope it works,  Just my 2 cents.
> 
> Ethan.zhao@oracle.com
> 
> On Wed, Nov 28, 2012 at 11:53 PM, Fujinaka, Todd <todd.fujinaka@intel.com> wrote:
>> The only EEPROM I know about or can speak to is the one attached to the 82571 and it doesn't set the MaxPayloadSize. That's done by the BIOS.
>>
>> Todd Fujinaka
>> Technical Marketing Engineer
>> LAN Access Division (LAD)
>> Intel Corporation
>> todd.fujinaka@intel.com
>> (503) 712-4565
>>
>>
>> -----Original Message-----
>> From: Joe Jin [mailto:joe.jin@oracle.com]
>> Sent: Wednesday, November 28, 2012 12:31 AM
>> To: Ben Hutchings
>> Cc: Fujinaka, Todd; Mary Mcgrath; netdev@vger.kernel.org; 
>> e1000-devel@lists.sf.net; linux-kernel@vger.kernel.org; linux-pci
>> Subject: Re: [E1000-devel] 82571EB: Detected Hardware Unit Hang
>>
>> On 11/28/12 02:10, Ben Hutchings wrote:
>>> On Tue, 2012-11-27 at 17:32 +0000, Fujinaka, Todd wrote:
>>>> Forgive me if I'm being too repetitious as I think some of this has 
>>>> been mentioned in the past.
>>>>
>>>> We (and by we I mean the Ethernet part and driver) can only change 
>>>> the advertised availability of a larger MaxPayloadSize. The size is 
>>>> negotiated by both sides of the link when the link is established.
>>>> The driver should not change the size of the link as it would be 
>>>> poking at registers outside of its scope and is controlled by the 
>>>> upstream bridge (not us).
>>> [...]
>>>
>>> MaxPayloadSize (MPS) is not negotiated between devices but is 
>>> programmed by the system firmware (at least for devices present at 
>>> boot - the kernel may be responsible in case of hotplug).  You can 
>>> use the kernel parameter 'pci=pcie_bus_perf' (or one of several 
>>> others) to set a policy that overrides this, but no policy will allow 
>>> setting MPS above the device's MaxPayloadSizeSupported (MPSS).
>>>
>>
>> Ben,
>>
>> Unfortunately I'm using 3.0.x kernel and this is not included in the kernel.
>> So I'm trying to use ethtool modify it from eeprom to see if help or no.
>>
>>
>> Todd, I'll review all MaxPayload for all devices, but need to say if it mismatch, customer could not modify it from BIOS for there was not entry at there, to test it, we have to find how to verify if this is the root cause, so still need to find the offset in eeprom.
>>
>> Thanks in advance,
>> Joe
>>


-- 
Oracle <http://www.oracle.com>
Joe Jin | Software Development Senior Manager | +8610.6106.5624
ORACLE | Linux and Virtualization
No. 24 Zhongguancun Software Park, Haidian District | 100193 Beijing 
