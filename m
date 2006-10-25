From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Wed, 25 Oct 2006 08:09:19 -0700
Message-ID: <453F7E1F.4020406@intel.com>
References: <45375135.5050206@cj.jp.nec.com> <45379C14.5050901@foo-projects.org> <4538BFF2.2040207@cj.jp.nec.com> <4538F080.5020003@intel.com> <453DD678.4010606@cj.jp.nec.com> <453E3C0B.5030600@intel.com> <453F6983.6020307@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:45176 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S932452AbWJYPLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 11:11:42 -0400
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <453F6983.6020307@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kenzo Iwami wrote:
> Hi,
> 
>>> This problem originally occurred in a very large cluster system using snmp
>>> for server management. About two servers panicked each day. The program I sent
>>> is to reproduce this problem in a very short time. It does occur under normal
>>> load when there is a lot of servers.
>> hmm, not good - does your snmp daemon use ethtool excessively? That would certainly be 
>> painful to the driver (any driver!).
> 
> I only looked at the panic message after this problem occurred.
> I could tell that the snmp daemon caused the panic while trying to process
> the ethtool's ioctl, but I don't know how often this was called.
> However, it shouldn't be excessively called because it occurred on a production
> system while it was idle.
> 
>> Anyway as I said in the same e-mail, we're working on reducing the lock timeout to a 
>> reasonable time. This will unfortunately take some time, as we need to change some major 
>> components in the driver to make sure this doesn't happen.
> 
> How about the following approach?
> If acquiring semaphore fails inside the interrupt handler, acquiring semaphore
> is abandoned immediately without waiting for timeout.
> However, I don't know whether this method affects other processes.

with the current hardware being accessed simultaneously from several users in the 
kernel, that would lead to large problems - the watchdog task accesses it every 2 
seconds as it reads the PHY link status, so when one of those fails the driver would 
have no choice but to reset the entire device.

Auke
