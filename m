From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 2/2]d80211: add hardware scan callback
Date: Wed, 30 Aug 2006 11:36:14 -0700
Message-ID: <44F5DA9E.9080103@linux.intel.com>
References: <1156494733.21483.14.camel@devlinux-hong> <20060830191058.14275f74@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hong Liu <hong.liu@intel.com>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:7072 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751225AbWH3SgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 14:36:15 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060830191058.14275f74@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3945 firmware and hardware still do time critical functions like  
Beaconing and power management. This restrict us once associated to 
switch channel from the driver. we need to unassociated first before 
switching to a new channel. Because of this restriction while 
associated  we can only call scan command and the firmware will take of 
tunning to available channels to listen to beacon and prob_resp.
Jiri Benc wrote:

>On Fri, 25 Aug 2006 16:32:13 +0800, Hong Liu wrote:
>  
>
>>Add hardware scan callback to support cards like ipw3945 which
>>implements the scan command in firmware.
>>    
>>
>
>How ipw3945 performs scan? From the patch, it looks like it switches
>channels (and sends probe requests) in the firmware and delivers all
>received beacons and probe responses through the normal rx path to be
>handled in a software MAC layer. This is really weird behaviour and
>doesn't make sense to me. Why isn't channel switching left to the
>software MAC as well?
>
>  
>
>>+/* set station scan completed */
>>+void ieee80211_set_scan_completed(struct net_device *dev);
>>    
>>
>
>Why "set"? "ieee80211_scan_completed" sounds better.
>
>Thanks,
>
> Jiri
>
>  
>
