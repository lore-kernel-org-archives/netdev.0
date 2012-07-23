From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: New commands to configure IOV features
Date: Mon, 23 Jul 2012 09:09:38 -0600
Message-ID: <500D6932.8090306@genband.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>			<5005D45D.1040302@genband.com>		 <20120717.141153.46613285253481776.davem@davemloft.net>		 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>	 <5009B186.6000806@genband.com> <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com> <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, yuvalmin@broadcom.com,
	gregory.v.rose@intel.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Don Dutile <ddutile@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <500D59BF.9040006@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/23/2012 08:03 AM, Don Dutile wrote:
> On 07/20/2012 07:42 PM, Chris Friesen wrote:
>>
>> I actually have a use-case where the guest needs to be able to modify 
>> the MAC addresses of network devices that are actually VFs.
>>
>> The guest is bonding the network devices together, so the bonding 
>> driver in the guest expects to be able to set all the slaves to the 
>> same MAC address.
>>
>> As I read the ixgbe driver, this should be possible as long as the 
>> host hasn't explicitly set the MAC address of the VF. Is that correct?
>>
>> Chris
>
> Interesting tug of war: hypervisors will want to set the macaddrs for 
> security reasons,
>                         some guests may want to set macaddr for 
> (valid?) config reasons.
>

In our case we have control over both guest an host anyways, so it's 
less of a security issue.  In the general case though I could see it 
being an interesting problem.

Back to the original discussion though--has anyone got any ideas about 
the best way to trigger runtime creation of VFs?  I don't know what the 
binary APIs looks like, but via sysfs I could see something like

echo number_of_new_vfs_to_create >  
/sys/bus/pci/devices/<address>/create_vfs

Something else that occurred to me--is there buy-in from driver 
maintainers?  I know the Intel ethernet drivers (what I'm most familiar 
with) would need to be substantially modified to support on-the-fly 
addition of new vfs.  Currently they assume that the number of vfs is 
known at module init time.

Chris
