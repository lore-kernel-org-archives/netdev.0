From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Tue, 24 Oct 2006 09:15:07 -0700
Message-ID: <453E3C0B.5030600@intel.com>
References: <45375135.5050206@cj.jp.nec.com> <45379C14.5050901@foo-projects.org> <4538BFF2.2040207@cj.jp.nec.com> <4538F080.5020003@intel.com> <453DD678.4010606@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49196 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1030414AbWJXQRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 12:17:34 -0400
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <453DD678.4010606@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kenzo Iwami wrote:
> Hi,
> 
> Thank you for your comment.
> 
>> This panic report falls in the category "how hard can I break my system as root". 
>> Explicitly abusing the system performing restricted calls depletes resources and 
>> harasses the sw lock (in this case). The reason that the driver attempts to wait that 
>> long is that in the case of ESB2 systems, the SPI interface to the EEPROM can be slow, 
>> thus taking a long time to complete certain commands.
> 
> This problem originally occurred in a very large cluster system using snmp
> for server management. About two servers panicked each day. The program I sent
> is to reproduce this problem in a very short time. It does occur under normal
> load when there is a lot of servers.

hmm, not good - does your snmp daemon use ethtool excessively? That would certainly be 
painful to the driver (any driver!).

Anyway as I said in the same e-mail, we're working on reducing the lock timeout to a 
reasonable time. This will unfortunately take some time, as we need to change some major 
components in the driver to make sure this doesn't happen.

Cheers,

Auke
