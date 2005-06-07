From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Mon, 06 Jun 2005 17:08:57 -0700
Message-ID: <42A4E599.2090604@candelatech.com>
References: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408> <Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ronciak, John" <john.ronciak@intel.com>,
        "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
        hadi@cyberus.ca, buytenh@wantstofly.org, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitch Williams wrote:
> 
> On Mon, 6 Jun 2005, Ronciak, John wrote:
> 
> 
>>>	If you force the e1000 driver to do RX replenishment every N
>>>	packets it should reduce the packet drops the same (in the
>>>	single NIC case) as if you reduced the dev->weight to that
>>>	same value N.
>>
>>But this isn't what we are seeing.  Even if we just reduce the weight
>>value to 32 from 64, all of the drops go away.  So there seems to be
>>other things affecting this.
> 
> 
> Some quickie results for everybody -- I've been working on other stuff this
> morning and haven't had much time in the lab.
> 
> Increasing the RX ring to 512 descriptors eliminates dropped packets, but
> performance goes down.  When I mentioned this, John and Jesse both nodded
> and said, "Yep.  That's what happens when the descriptor ring grows past
> one page."
> 
> Reducing the weight to 32 got rid of almost all of the dropped packets
> (down to < 1 per second); reducing it to 20 eliminated all of them.  In
> both cases performance rose as compared to the default weight of 64.
> 
> Tests were run on 2.6.12rc5 on a dual Xeon 2.8GHz PCI-X system.  We run
> Chariot for performance testing, using TCP/IP large file transfers with 10
> Windows 2000 clients.

So is the Linux server reading/writing these large files to/from the disk?

Can you tell us how much performance went down when you increased the
descriptors to 512?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
