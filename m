From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net/wireless: enable wiphy device to suspend/resume
 asynchronously
Date: Mon, 17 Aug 2015 09:29:13 +0200
Message-ID: <1439796553.2451.1.camel@sipsolutions.net>
References: <55B9B3BA.6080406@linux.intel.com>
	 <CANUX_P3PMsvWCWWciwCsRvf5PqLVEK9d9S=2Gbq+EotVGffEow@mail.gmail.com>
	 <55D13D66.1050500@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>,
	Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43082 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750775AbbHQH3W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 03:29:22 -0400
In-Reply-To: <55D13D66.1050500@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-17 at 09:48 +0800, Fu, Zhonghui wrote:
> 
> The suspend/resume timing of wiphy device and related devices will be 
> ensured by their parent/child relationship. So, enabling wiphy device 
> to suspend/resume asynchronously does not change any  dependency. It 
> can only take advantage of multicore and improve system 
> suspend/resume speed.
> 

You're going to have to explain that to me, because I don't see that.
All I see is that when looking at a device, if async is possible, it
gets added to an async work, and if async is not possible then it gets
done immediately. Even putting aside the question of whether or not
async is ordered or not (I don't know), if the wiphy is async and the
PCI (or other bus) device isn't, then it seems they could get handled
out of order, no? Or is there some magic code somewhere that I'm
missing that explicitly waits for the async of the parent/child
relationship?

johannes
