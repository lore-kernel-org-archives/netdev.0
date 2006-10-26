From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Thu, 26 Oct 2006 19:35:39 +0900
Message-ID: <45408F7B.3050209@cj.jp.nec.com>
References: <45375135.5050206@cj.jp.nec.com> <45379C14.5050901@foo-projects.org> <4538BFF2.2040207@cj.jp.nec.com> <4538F080.5020003@intel.com> <453DD678.4010606@cj.jp.nec.com> <453E3C0B.5030600@intel.com> <453F6983.6020307@cj.jp.nec.com> <453F7E1F.4020406@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([210.143.35.52]:30638 "EHLO
	tyo202.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S1422976AbWJZKgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 06:36:17 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <453F7E1F.4020406@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for your comment.

>>> Anyway as I said in the same e-mail, we're working on reducing the lock timeout to a 
>>> reasonable time. This will unfortunately take some time, as we need to change some major 
>>> components in the driver to make sure this doesn't happen.
>>
>> How about the following approach?
>> If acquiring semaphore fails inside the interrupt handler, acquiring semaphore
>> is abandoned immediately without waiting for timeout.
>> However, I don't know whether this method affects other processes.
> 
> with the current hardware being accessed simultaneously from several users in the 
> kernel, that would lead to large problems - the watchdog task accesses it every 2 
> seconds as it reads the PHY link status, so when one of those fails the driver would 
> have no choice but to reset the entire device.

This problem occurs because interrupt handler is executed while the
interrupted code is still holding the semaphore. Acquiring the semaphore
fails regardless of the timeout period.

I think the watchdog task will fail trying to read the PHY link status,
even if the lock timeout period has been reduced.

-- 
  Kenzo Iwami (k-iwami@cj.jp.nec.com)
