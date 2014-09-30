From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] xen/xenbus: Use 'void' instead of 'int' for the return
 of xenbus_switch_state()
Date: Tue, 30 Sep 2014 16:04:33 +0800
Message-ID: <542A6411.5040201@gmail.com>
References: <5425961A.5000604@gmail.com> <20140929140229.GA28279@laptop.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>, ian.campbell@citrix.com,
	wei.liu2@citrix.com, boris.ostrovsky@oracle.com,
	bhelgaas@google.com, jgross@suse.com,
	yongjun_wei@trendmicro.com.cn, mukesh.rathor@oracle.com,
	xen-devel@lists.xenproject.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20140929140229.GA28279@laptop.dumpdata.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/29/14 22:02, Konrad Rzeszutek Wilk wrote:
> On Sat, Sep 27, 2014 at 12:36:42AM +0800, Chen Gang wrote:
>> When xenbus_switch_state() fails, it will call xenbus_switch_fatal()
> 
> Only on the first depth, not on the subsequent ones (as in if
> the first xenbus_switch_fail fails, it won't try to call
> xenbus_switch_state again and again).
> 

Yeah, I guess you want to give more completion for this comment, do not
mean the original comments is incorrect.

[...]
>>
>> Also need be sure that all callers which check the return value must let
>> 'err' be 0.
> 
> I am bit uncomfortable with that, that is due to:
> 
> 
> .. snip..
>> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
>> index 9c47b89..b5c3d47 100644
>> --- a/drivers/net/xen-netback/xenbus.c
>> +++ b/drivers/net/xen-netback/xenbus.c
>> @@ -337,10 +337,7 @@ static int netback_probe(struct xenbus_device *dev,
>>  	if (err)
>>  		pr_debug("Error writing multi-queue-max-queues\n");
>>  
>> -	err = xenbus_switch_state(dev, XenbusStateInitWait);
>> -	if (err)
>> -		goto fail;
>> -
>> +	xenbus_switch_state(dev, XenbusStateInitWait);
> 
> Which if it fails it won't call:
> 
> 354 fail:                                                                           
> 355         pr_debug("failed\n");                                                   
> 356         netback_remove(dev);                                                    
> 357         return err;         
> 

Originally, I intended left 'fail' code block for the next patch (which
I thought the next patch would need it).

Hmm... but any way, originally, I really need give additional comments
for it.

[...]

I skip all other contents which have already discussed by maintainers,
if I really miss something, please let me know.


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
