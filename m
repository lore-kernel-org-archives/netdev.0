From: Ben Greear <greearb@candelatech.com>
Subject: Re: skge: reboot on sysfs resource0 access
Date: Fri, 09 Sep 2005 11:21:52 -0700
Message-ID: <4321D2C0.10800@candelatech.com>
References: <200509091938.18079.bernd.schubert@pci.uni-heidelberg.de> <20050909110153.5a2e2e90@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bernd-schubert@gmx.de, bernd.schubert@pci.uni-heidelberg.de,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050909110153.5a2e2e90@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 9 Sep 2005 19:38:17 +0200
> Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de> wrote:
> 
> 
>>Hello,
>>
>>today we tried 2.6.13 on our server and also tried to use the skge driver. 
>>Well, in principle it works fine, until I became curious about the sysfs 
>>values. Stupid me, I was using the midnight commander to read the values. 
>>When I opened "/sys/bus/pci/drivers/skge/0000:01:01.0/resource0", the system 
>>immediately rebooted. After the reboot we tested using cat to the resource0 
>>file, which gave an input/output error. Using again the mc, the system again 
>>immediately rebooted.
>>Well, I guess I better don't use the midnight commander in the future, but 
>>somehow I think it shouldn't cause the system to reboot, should it? Is the 
>>i/o error of cat supposed to happen?
>>
> 
> 
> Don't do that!  resource0 is the pci space for the card and
> reading it directly accesses the memory mapped space. The
> register is sparse, and some places are unaccessable. 
> Accessing non-existent memory will cause system to hang and if you
> are lucky a timeout and reboot.
> 
> Sorry, this is not a driver bug.

Does that mean if you do this:

find /sys -name "*" -print|xargs grep foo

that the system will crash?

I certainly would consider that a bug, and even if that somehow works, I'd
think that at the least you should be able to read every file in the file
system without crashing the system!

Do you at least have to be root to cause this crash?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
