From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Consolidate multiple implementations of jiffies-msecs
 conversions.
Date: Fri, 26 Mar 2004 14:03:01 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40647E65.7020903@pobox.com>
References: <Pine.LNX.4.58.0403251142110.3037@localhost.localdomain> <20040326014403.39388cb8.froese@gmx.de> <Pine.LNX.4.58.0403261007370.6718@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Edgar Toernig <froese@gmx.de>, davem@redhat.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0403261007370.6718@localhost.localdomain>
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> On Fri, 26 Mar 2004, Edgar Toernig wrote:
> 
> 
>>Sridhar Samudrala wrote:
>>
>>>The following patch to 2.6.5-rc2 consolidates 6 different implementations
>>>of msecs to jiffies and 3 different implementation of jiffies to msecs.
>>>All of them now use the generic msecs_to_jiffies() and jiffies_to_msecs()
>>>that are added to include/linux/time.h
>>>[...]
>>>-#define MSECS(ms)  (((ms)*HZ/1000)+1)
>>>-return (((ms)*HZ+999)/1000);
>>>+return (msecs / 1000) * HZ + (msecs % 1000) * HZ / 1000;
>>
>>Did you check that all users of the new version will work correctly
>>with your rounding?  Explicit round-up of delays is often required,
>>especially when talking to hardware...
> 
> 
> I don't see any issues with the 2.6 default HZ value of 1000 as they become
> no-ops and there is no need for any rounding.
> I guess you are referring to cases when HZ < 1000(ex: 100) and msecs is
> less than 10. In those cases, the new version returns 0, whereas some of the
> older versions return 1.

We'll definitely want to return 1 rather than zero, for the uses in my 
drivers, at least...

	Jeff
