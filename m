From: Michal Privoznik <mprivozn@redhat.com>
Subject: Re: [PATCH] net-sysfs: Report link speed only when possible
Date: Fri, 13 Jun 2014 11:19:51 +0200
Message-ID: <539AC237.40402@redhat.com>
References: <771f792d4d4391c656305a522557c53c4e84a666.1402043894.git.mprivozn@redhat.com>	<20140606085733.GJ2984@minipsycho.orion> <20140606.125447.1665616708152334692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jiri@resnulli.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140606.125447.1665616708152334692.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06.06.2014 21:54, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Fri, 6 Jun 2014 10:57:33 +0200
>
>> Fri, Jun 06, 2014 at 10:40:30AM CEST, mprivozn@redhat.com wrote:
>>> The link speed is available at /sys/class/net/$nic/speed.
>>> However, in some cases, depending on the driver, if the link is
>>> not plugged, -1 is reported (this is the case of e1000e for
>>> instance). To make things worse, the value is printed out as an
>>
>> Actually, SPEED_UNKNOWN is also -1
>> So e1000e is not any exception.
>
> And pity the person who is handling this by evaluating that unsigned
> value, we'll break them.
>
> We can't keep changing behavior for the SPEED_UNKOWN case back and
> forth.
>
> A program that wants to work with all kernels now has to handle three
> different kinds of behavior if we apply this patch, that's not making
> things better, it's making things worse.

I don't think this is a good reason to keep things broken. By the same 
token we wouldn't need to fix any bug since there already might be an 
application that learned how to deal with it.

This patch is not introducing any new class that applications need to 
learn. It just barely removes the spurious one. And it's perfectly okay 
in some ecosystems to require minimal version of some programs, 
including kernel. So if I were developing brand new application I could 
say: I'm dropping all this workaround code and have it clean and require 
say 3.16 kernel at least. Moreover, using an older application would do, 
as the workaround code will never be executed.

But okay, maybe for some reason you're hesitant to change net-sysfs.c. 
Would it be more convenient to change the broken drivers instead? Yes, 
some drivers don't report nor 0, nor -1, but rather random value. For 
instance a tap device returns '10',  igb '65535', etc.

Michal
