From: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
Subject: Re: [PATCH] mrf24j40: seperate mrf24j40 h/w
	init and add checkings
Date: Thu, 24 Apr 2014 08:49:44 +0530
Message-ID: <535882D0.8000600@cdac.in>
References: <1398258716-18319-1-git-send-email-varkab@cdac.in>
	<5357C565.8080009@signal11.us> <20140423140007.GA24286@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20140423140007.GA24286@omega>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alan,

My view is same as Alex view. If spi_sync() is not able to write and get 
the data we will get
an error number return.

The driver is allocating so many kernel resources even if you get the 
errno return also.
So this patch will return from driver probe() if spi_sync() returns err.

Thanks and Regards,
Varka Bhadram

On 04/23/2014 07:30 PM, Alexander Aring wrote:
> Hi Alan,
>
> On Wed, Apr 23, 2014 at 09:51:33AM -0400, Alan Ott wrote:
>> On 04/23/2014 09:11 AM, Varka Bhadram wrote:
>>> I followed the process that you mailed earlier, thnks for that.
>>>
>>> I am expecting the mail from Alan about the changes.
>> Hi Varka,
>>
>> Is there a specific problem you're seeing? Typically in the kernel we expect
>> the SPI controller to succeed for a couple reasons:
>> 1. It's part of the basic, core functionality of a system. Checking for
>> errors on SPI transfers is analogous to making sure RAM you wrote actually
>> got written.
>> 2. Most of the time an SPI failure is not something we can detect anyway.
>> (disconnect one of the lines and see what you get).
>> 3. The code to check for it just adds a lot of bloat without much measurable
>> benefit.
>>
>> I've read the above in the comments in other drivers, but I can't remember
>> exactly where right now. There are plenty of examples in the kernel of SPI
>> being done this way, as it seems to be accepted practice in the kernel.
>>
>> If there is a specific issue that you're seeing, then let's talk about it,
>> otherwise I'm going to NAK this change.
>>
> if somebody hasn't a right spi configuration the probe function should
> fail. Assumed that spi_sync will return a errno then.
>
> - Alex


-------------------------------------------------------------------------------------------------------------------------------

This e-mail is for the sole use of the intended recipient(s) and may
contain confidential and privileged information. If you are not the
intended recipient, please contact the sender by reply e-mail and destroy
all copies and the original message. Any unauthorized review, use,
disclosure, dissemination, forwarding, printing or copying of this email
is strictly prohibited and appropriate legal action will be taken.
-------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
